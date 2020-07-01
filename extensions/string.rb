class String
  BLANK_RE = /\A[[:space:]]*\z/

  def present?
    !BLANK_RE.match?(self)
  end
end
