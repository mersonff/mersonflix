class Category < ApplicationRecord
  validates_presence_of :title, :color

  validate :first_category_should_be_free

  paginates_per 5

  private

    def first_category_should_be_free
      unless !Category.all.empty?
        if (self.title != 'LIVRE' && self.id = 1)
          errors.add(:title, :first_category_should_be_free)
        end
      end
    end
  end