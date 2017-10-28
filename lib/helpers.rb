module Helpers
  def partial(template, locals = {})
    slim template, :layout => false, :locals => locals
  end

  def find_template(views, name, engine, &block)
    views.each { |v| super(v, name, engine, &block) }
  end

  def user_pass
    user = Nutzer.where(:US_LoginName => request.env["REMOTE_USER"]).first
    return "" if user.nil?
    [user.login, user.crypt(user.password)]
  end

  def dokumente(repos, fachklasse, abschnitt)
    ary = repos.select{|r|r.enabled?}.map do |repo|
      docs = repo.documents.select do |d|
        (d.get("Ignoriere-Abschnitt") != abschnitt) && (d.verfuegbar(fachklasse))
      end
      next if docs.empty?
      docs.sort_by!{|d|d.get "Name"}
      [repo.repo_name, docs]
    end
    ary.compact.to_h
  end

  def restart
    puts "Server neu starten …"
    File.open("./tmp/restart.txt", "w"){}
  end
end


