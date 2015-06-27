class BranchCommitMeta
	include Mongoid::Document

	#uniqueness factors
	field :created_at_date,type: Date
	field :branch, type: String
	field :email, type: String

	field :day, type: Integer
	field :year, type: Integer
	field :month, type: Integer
	field :week, type: Integer
	field :cwday, type: Integer
	field :timestamp, type: Integer

	field :commits, type: Integer

	field :hourly_commits,type: Hash,default: {0 => 0,1 => 0,2 => 0,3 => 0,4 => 0,5 => 0,6 => 0,7 => 0,8 => 0,9 => 0,10 => 0,11 => 0,12 => 0,13 => 0,14 => 0,15 => 0,16 => 0,17 => 0,18 => 0,19 => 0,20 => 0,21 => 0,22 => 0,23 => 0}

	before_create :init_object

	def init_object
		date = self.created_at_date
		self.day = date.day
		self.year = date.year
		self.month = date.month
		self.week = date.cweek
		self.cwday = date.cwday
		self.timestamp = (self.created_at_date.to_time.to_f*1000).to_i
		return true
	end

	def get_report(group_by="daily")
		hash = {}
		if group_by == "daily"
			hash[self.timestamp] = {commits: self.commits}
		else
			24.times do |hour|
				hash[(self.timestamp+3600000*hour)] = {commits: self["hourly_commits.#{hour}"]}
			end
		end
	end

end
