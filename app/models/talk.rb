class Talk < ActiveRecord::Base
  belongs_to :user
  belongs_to :venue
  belongs_to :camp #denormalized from venue because talks start off w/out a venue when a camp is created

  validates_presence_of :user_id
  validates_presence_of :venue_id
  validates_presence_of :start_at
  validates_presence_of :end_at
  validate :start_at_is_less_than_end_at

  scope :after, lambda { |time| where("start_at >= :time", :time => time) }
  scope :before, lambda { |time| where("start_at <= :time", :time => time) }
  scope :for_day, lambda { |day| self.after(day.beginning_of_day).before(day.end_of_day).order(:start_at) }
  scope :in_progress, lambda { self.before(Time.now).where("end_at > :time", :time => Time.now) }

  def self.for_venue(venue)
    where(:venue_id => venue.id)
  end

  def day
    start_at.to_date
  end
  
  def duration
    end_at - start_at
  end
  
  def remaining
    remnants = end_at - Time.now
    remnants = [duration, remnants].min # To cap it at the talk's length
    [0, remnants].max # So that we don't end up with a negative time if it's in the past.
  end

  private

  def start_at_is_less_than_end_at
    if start_at.blank? || end_at.blank? || start_at >= end_at
      errors.add :start_at, "The start time must be before the end time" 
    end
  end
end
