module Mongo::CollectionFinders
  #
  # first_by_id, special case
  #
  def first_by_id id
    first _id: id
  end
  alias_method :by_id, :first_by_id

  def first_by_id! id
    first_by_id(id) || raise(Mongo::NotFound, "document with id #{id} not found!")
  end
  alias_method :by_id!, :first_by_id!

  protected
    #
    # first_by_field, all_by_field
    #
    def method_missing clause, *a, &b
      if clause =~ /^([a-z]_by_[a-z_])|(by_[a-z_])/
        clause = clause.to_s

        bang = clause =~ /!$/
        clause = clause[0..-2] if bang

        finder, field = if clause =~ /^by_/
          ['first', clause.sub(/by_/, '')]
        else
          clause.split(/_by_/, 2)
        end
        finder = 'first' if finder == 'find'

        raise "You can't use bang version with :#{finder}!" if bang and finder != 'first'

        raise "invalid arguments for finder (#{a})!" unless a.size == 1
        field_value = a.first

        send(finder, field => field_value) || (bang && raise(Mongo::NotFound, "document with #{field}: #{field_value} not found!"))
      else
        super
      end
    end
end