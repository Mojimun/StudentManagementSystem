class Subject < ApplicationRecord
  belongs_to :student

  def self.subject_wise_students_count
    data = {"JavaScript" => 0, "Ruby on Rails" => 0, "Python" => 0}
    student_count = Subject.select('COUNT(*) as count, subjects.name as name').joins(:student).group('subjects.name')
    student_count.each do |cnt|
      data[cnt[:name]] = cnt[:count]
    end
    return data
  end
end
