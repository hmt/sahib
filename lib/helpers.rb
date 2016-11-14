module Helpers
  def partial(template, locals = {})
    slim template, :layout => false, :locals => locals
  end

  def find_template(views, name, engine, &block)
    views.each { |v| super(v, name, engine, &block) }
  end

  def user_pass
    user = Nutzer.where(:US_LoginName => request.env["REMOTE_USER"]).first
    {:u => user.login,
     :p => user.crypt(user.password)}
  end

  def dokumente(repos)
    unsortiert = repos.select{|r|r.enabled?}.inject([]) do |dokumente, repo|
      dokumente + repo.documents
    end
    unsortiert ? unsortiert.sort_by{|d|d.get "Name"} : []
  end

  def restart
    puts "Server neu starten …"
    File.open("./tmp/restart.txt", "w"){}
  end
end


