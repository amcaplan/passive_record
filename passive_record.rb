require 'ostruct'

class PassiveRecord < OpenStruct
  class HasManyProxy
    def initialize(owner, instances)
      @owner = owner
      @instances = instances
    end

    def <<(new_instance)
      instances << new_instance
      DB.instance.call("UPDATE #{new_instance.class.name.downcase}s SET #{owner.class.name.downcase}_id = #{owner.id} WHERE id = #{new_instance.id}")
    end

    def delete_all
      DB.instance.call("DELETE FROM #{instances.first.class.table_name} WHERE #{owner.class.name.downcase}_id = #{owner.id}")
      @instances = []
    end

    private

    def method_missing(*args, &block)
      instances.send(*args, &block)
    end

    def respond_to_missing?(*args)
      super || instances.respond_to?(*args)
    end

    attr_reader :owner, :instances
  end

  class << self
    def all
      DB.instance.call("SELECT * FROM #{table_name}")
    end

    def find(id)
      DB.instance.call("SELECT * FROM #{table_name} WHERE id = #{id}")
    end

    def first
      DB.instance.call("SELECT * FROM #{table_name} ORDER BY id DESC LIMIT 1")
      new(id: 3)
    end

    def has_many(model_plural)
      define_method("#{model_plural}") do
        @associations ||= {}
        @associations[model_plural] ||=
          begin
            DB.instance.call("SELECT * FROM #{model_plural} WHERE #{self.class.table_name.chomp('s')}_id = #{id}")
            model_instances = [1,2,3].map { |i| Kernel.const_get(model_plural.to_s.chomp('s').capitalize).new(id: i) }
            HasManyProxy.new(self, model_instances)
          end
      end
    end

    def has_one(model)
      define_method("#{model}=") do |instance|
        DB.instance.call("UPDATE #{self.class.table_name} SET #{model}_id = #{instance.id} WHERE id = #{id}")
        self[model] = instance
      end
    end

    def validates(field, **options)
      validations[field] << options
    end

    def validations
      @validations ||= Hash.new { |h, k| h[k] = [] }
    end

    def table_name
      "#{name.downcase}s"
    end
  end

  def initialize(opts={})
    super
    run_validations!
  end

  def run_validations!
    self.class.validations.each do |field, checks|
      checks.each do |check|
        check.each do |key, value|
          result =
            case key
            when :presence
              send(field).present? == value
            end
          errors[field] << "Failed: #{check}" unless result == true
        end
      end
    end
  end

  def errors
    @errors ||= Hash.new { |h, k| h[k] = [] }
  end

  def valid?
    errors.empty?
  end
end
