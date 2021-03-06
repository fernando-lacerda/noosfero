require 'csv'

class UsersController < AdminController

  protect 'manage_environment_users', :environment

  include UsersHelper

  def index
    @filter = params[:filter] || 'all_users'
    scope = environment.people.no_templates
    if @filter == 'admin_users'
      scope = scope.admins
    elsif @filter == 'activated_users'
      scope = scope.activated
    elsif @filter == 'deactivated_users'
      scope = scope.deactivated
    elsif @filter == 'recently_logged_users'
      days = 90
      scope = scope.recent

      if params[:filter_number_of_days] == nil
        scope = scope.where('last_login_at > ?', (Date.today - 0))
      else
        days = 100000
        hash = params[:filter_number_of_days]
        days = hash[:"{:controller=>\"user\", :action=>\"index\"}"]
        scope = scope.where('last_login_at > ?', (Date.today - days.to_i))
      end
    end
    scope = scope.order('name ASC')
    @q = params[:q]
    @collection = find_by_contents(:people, environment, scope, @q, {:per_page => per_page, :page => params[:npage]})[:results]
  end

  def set_admin_role
    person = environment.people.find(params[:id])
    environment.add_admin(person)
    redirect_to :action => :index, :q => params[:q], :filter => params[:filter]
  end

  def reset_admin_role
    person = environment.people.find(params[:id])
    environment.remove_admin(person)
    redirect_to :action => :index, :q => params[:q], :filter => params[:filter]
  end

  def activate
    person = environment.people.find(params[:id])
    person.user.activate
    redirect_to :action => :index, :q => params[:q], :filter => params[:filter]
  end

  def deactivate
    person = environment.people.find(params[:id])
    person.user.deactivate
    redirect_to :action => :index, :q => params[:q], :filter => params[:filter]
  end

  def destroy_user
    if request.post?
      person = environment.people.find_by id: params[:id]
      if person && person.destroy
        session[:notice] = _('The profile was deleted.')
      else
        session[:notice] = _('Could not remove profile')
      end
    end
    redirect_to :action => :index, :q => params[:q], :filter => params[:filter]
  end

  def download
    respond_to do |format|
      format.html
      format.xml do
        users = User.where(:environment_id => environment.id).includes(:person)
        send_data users.to_xml(
            :skip_types => true,
            :only => %w[email login created_at updated_at last_login_at],
            :include => { :person => {:only => %w[name updated_at created_at address birth_date contact_phone identifier lat lng] } }),
          :type => 'text/xml',
          :disposition => "attachment; filename=users.xml"
      end
      format.csv do
        # using a direct connection with the dbms to optimize
        command = User.send(:sanitize_sql, ["SELECT profiles.name, users.email, users.last_login_at FROM profiles
                                             INNER JOIN users ON profiles.user_id=users.id
                                             WHERE profiles.environment_id = ?", environment.id])
        users = User.connection.execute(command)
        csv_content = "name;email;last_login_at\n"
        users.each { |u|
          csv_content << CSV.generate_line([u['name'], u['email'], u['last_login_at']], {:col_sep => ';'})
        }
        render :text => csv_content, :content_type => 'text/csv', :layout => false
      end
    end
  end

  def send_mail
    if request.post?
      @mailing = environment.mailings.build(params[:mailing])
      @mailing.recipients_roles = []
      @mailing.recipients_roles << "profile_admin" if params[:recipients][:profile_admins].include?("true")
      @mailing.recipients_roles << "environment_administrator" if params[:recipients][:env_admins].include?("true")
      @mailing.locale = locale
      @mailing.person = user
      if @mailing.save
        session[:notice] = _('The e-mails are being sent')
        redirect_to :action => 'index'
      else
        session[:notice] = _('Could not create the e-mail')
      end
    end
  end

  private

  def per_page
    10
  end

end
