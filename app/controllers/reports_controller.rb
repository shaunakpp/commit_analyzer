class ReportsController < ActionController::Base
	before_action :authenticate_user!
	layout "report1", :only => :report1
	def report1
		render template: "common"
	end

	def get_data
		json = {}

		branch = params[:branch]
		email = params[:user]
		matcher = {}
		if(params[:date].present?)
			start_date = params[:date].split("-")[0].rstrip
			end_date = params[:date].split("-")[1].lstrip
			matcher = {created_at_date: {'$gte' =>  Time.parse(start_date).beginning_of_day, '$lte' => Time.parse(end_date).end_of_day}}
		end
		matcher[:cwday] = params[:day].to_i if(params[:day].present?)

		matcher[:email] = email if(email.present?)
		if(params[:type].present?)
			type = params[:type]
		else
			type="daily"
		end
		if(branch.present?)
			matcher[:branch] = branch
			metas = BranchCommitMeta.where(matcher)
		else
			metas = CommitMeta.where(matcher)
		end
		metas.asc(:created_at_date).each do |cmi|
			hash = cmi.get_report(type)
			hash.keys.each_with_index do |key, i|
				if(!json.has_key?(key))
					json[key] = {commits: 0}
				end
				json[key].update(hash.values[i]) {|k,v1,v2| v1+v2}
			end
		end
		render json: json
	end


	def data_provider
		@committers = Committer.all
		regex = Regexp.new(".*" + params[:q] + ".*","i")
		@committers = @committers.where({"name" =>  regex})
		respond_to do |format|
			format.json{render json: @committers.collect{|x| {id: x.email, text: x.name}}}
		end
	end

end
