class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities

    can :manage, User, :id => user.id
    can :manage, UserProfile, :user_id => user.id
    can :create, Request

    if user.role_name == "requester"
      can :read, Request, :user_id => user.id
      can [:update, :destroy], Request do |r|
        r.user == user && r.editable_by_requester?
      end
      # Requester can accept, submit or cancel his own requests, but only when
      # state_machines allows to do it
      [:submit, :accept, :cancel].each do |action|
        can action, Request do |r|
          r.user == user && r.send("can_#{action}?")
        end
      end
      can :manage, User, :id => user.id
    elsif user.role_name == "tsp"
      can :read, Request
      can :update, Request do |r|
        r.editable_by_tsp?
      end
      # TSP members can approve, reject or cancel any request, but only when
      # state_machines allows to do it
      [:approve, :reject, :cancel].each do |action|
        can action, Request do |r|
          r.send("can_#{action}?")
        end
      end
    end
  end
end