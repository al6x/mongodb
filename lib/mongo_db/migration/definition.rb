class Mongo::Migration::Definition
  def upgrade &block
    if block
      @upgrade = block
    else
      @upgrade
    end
  end
  alias_method :up, :upgrade

  def downgrade &block
    if block
      @downgrade = block
    else
      @downgrade
    end
  end
  alias_method :down, :downgrade
end