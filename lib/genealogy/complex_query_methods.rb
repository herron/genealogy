module Genealogy
  module ComplexQueryMethods
    extend ActiveSupport::Concern
    include Constants

    def least_common_ancestor(other_person)
      raise ArgumentError, "argument must be an instance of the #{gclass} class" unless other_person.is_a? gclass
      self_parent_ids = [self.id]
      other_parent_ids = [other_person.id]

      generation_count = 1

      self_ancestor_record_ids = [self.id]
      other_ancestor_record_ids = [other_person.id]

      while self_parent_ids.length > 0 || other_parent_ids.length > 0
        self_next_gen = gclass.select(:father_id, :mother_id).where(id: self_parent_ids).pluck(:father_id, :mother_id).flatten.compact
        other_next_gen = gclass.select(:father_id, :mother_id).where(id: other_parent_ids).pluck(:father_id, :mother_id).flatten.compact

        self_ancestor_record_ids += self_next_gen
        self_parent_ids = self_next_gen

        other_ancestor_record_ids += other_next_gen
        other_parent_ids = other_next_gen

        if (self_ancestor_record_ids & other_ancestor_record_ids).length > 0
          return gclass.where(id: (self_ancestor_record_ids & other_ancestor_record_ids))
        else
          generation_count += 1
        end
      end
      gclass.where(id: nil)
    end


  end
end