namespace :agile do
  desc "create acitivities from yaml"
  task :create_activity => :environment do
    Activity.delete_all
    activities = YAML.load_file("#{Rails.root}/config/activity.yml")
    activities.each do |key, activity|
      puts activity.inspect
      room = ''
      activity.delete_if { |k,v| v == " - " }
      activity = Hash[activity.map { |k, v| [k =~ /^Room/ ?  'room' : k, k =~ /^Room/ && v != nil ? room = room + k + ': ' + v + "\n"  : v ] }]
      activity = Hash[activity.map { |k, v| [k.underscore.sub(" ", "_").to_sym, v =~ /^\d+$/ ?  v.try(:to_i) : v] }]
      activity = Hash[activity.map { |k, v| [ k, k.to_s =~ /time$/ ?  DateTime.strptime( v, "%m/%d/%Y %H:%M") : v] }]

      puts activity.inspect
      puts "**********************************************"
      Activity.create(activity)
    end
  end

  desc "Create the feedback question and answers for each activity."
  task :create_feedback => :environment do

    QUESTIONS = [
      ['1.What is your overall impression of the content of this sessionession?', ['Very valuable', 'Valuable', 'Somewhat valuable', 'Not valuable']],
      ['2.Do you have any comments on the session (clarity, speaker, usefulness etc.)?', nil],
      ['3.What other suggestions for Technology & Innovation do yamlou have?',  nil]
    ]

    activities = Activity.where("speakers != ''")

    activities.each do |activity|
      QUESTIONS.each do |question|
        title, answers = question
        q = Question.new(title: title,  default_answers: answers )
        activity.questions << q
      end
    end
  end

  desc "Drop all the question and answers."
  task :drop_feedback => :environment do
    Answer.delete_all
    Question.delete_all
  end

  desc 'export answers'
  task :export_answers => :environment do
     File.open("#{Rails.root}/tmp/result.csv", 'w') do |f|

       Answer.all.each do |answer|
         f.write("%s,%s,%s\n" % [answer.question.activity.title, answer.question.title, answer.content])
      end
     end
  end
end
