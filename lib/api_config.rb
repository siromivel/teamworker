# /lib/api_config.rb
require 'httparty'

module Api_Config
  class TeamWork
    include HTTParty
    BASE_URI = "http://searchspring.teamwork.com"

    def time_setter(start, duration=0)
      the_time = Time.now + duration.to_i * 86400
      year = the_time.year
      month = the_time.month
      day = the_time.day

      return 
    end

    def create_project(name, duration, pop=false)
      start_year = Time.now.year
      start_month = Time.now.month
      start_day = Time.now.day
      start_date = '%02d' % start_year + '%02d' % start_month + '%02d' % start_day

      due_time = Time.now + duration.to_i * 86400
      due_year = due_time.year
      due_month = due_time.month
      due_day = due_time.day
      due_date = '%02d' % due_year.to_s.strip + '%02d' % due_month.to_s.strip + '%02d' % due_day.to_s.strip

      data = jsonify(File.read('template.json'))
      data["project"]["name"] = name
      data["project"]["startDate"] = start_date
      data["project"]["endDate"] = due_date
      
      req = postreq("/projects.json", data)
      new_id = req["id"]
      
      return populate(new_id)
    end

    def projects
      @options[:query] = "status=ALL"
      endpoint = "/projects.json"
      response = jsonify(getreq(endpoint).body)
      return response
    end

    def initialize(u, p)
      auth = {:username => u, :password => p}
      @options = {:basic_auth => auth}
    end

    def populate(id)
      stones = milestones
      notes = notebooks
      lists = tasklists

      stones.each do |m|
        path = "/projects/" + id + "/milestones.json"
        payload = {}
        payload["milestone"] = m
        postreq(path, payload)
      end

      notes.each do |n|
        path = "/projects/" + id + "/notebooks.json"
        payload = {}
        payload["notebook"] = n
        payload["notebook"]["content"] = ""
        postreq(path, payload)
      end

      lists.each do |l|
        path = "/projects/" + id + "/tasklists.json"

        payload = {}
        payload["todo-list"] = l
        
        list_id = payload["todo-list"]["id"]
        list_tasks = tasks(list_id)
        
        target_list = postreq(path, payload)["TASKLISTID"]

        list_tasks.each do |t|
          path = "/tasklists/" + target_list + "/tasks.json"
          task_payload = {}
          task_payload["todo-item"] = t
          task_payload["todo-item"]["parentTaskId"] = 0

          postreq(path, task_payload)
        end
      end

      return id
    end

    def dummy
    	endpoint = "/projects.json"
      response = jsonify(getreq(endpoint).body)
      dummy = projects["projects"].find {|p| p["name"] == "btosports.com"}["id"]
      return dummy
    end

    def milestones
    	endpoint = "/projects/" + dummy + "/milestones.json"
      response = jsonify(getreq(endpoint).body)
      return response["milestones"]
    end

    def notebooks
    	@options[:query] = "includeContent=true"
      endpoint = "/projects/" + dummy + "/notebooks.json"
      response = jsonify(getreq(endpoint).body)
      return response["project"]["notebooks"]
    end

    def tasks(list)
      @options[:query] = "filter=all"
      endpoint = "/tasklists/" + list + "/tasks.json"
      response = jsonify(getreq(endpoint).body)
      return response["todo-items"]
    end

    def tasklists
      @options[:query] = nil
      endpoint = "/projects/" + dummy + "/tasklists.json"
      response = jsonify(getreq(endpoint).body)
      return response["tasklists"]
    end

    def getreq(path)
      self.class.get(BASE_URI + path, @options)
    end

    def postreq(path, data)
    	@options[:headers] = { 'Content-Type' => 'application/json' }
    	@options[:query] = nil
    	@options[:body] = data.to_json
      self.class.post(BASE_URI + path, @options)
    end

    def jsonify(res)
      json = JSON.parse(res)
    end

    private :dummy, :getreq, :initialize, :jsonify, :milestones, :notebooks, :postreq, :tasklists
  end
end