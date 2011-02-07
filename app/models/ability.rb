class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here.
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities

    can :read, :all

    if user  # logged in
      if user.is_admin?
        can :manage, :all                     # admin can do anything
        cannot :update, Comment do |comment|  # except modify others' comments
          comment.commenter != user
        end
      else
        can :create, Product
        can [:update, :delete, :add_platform], Product, :publisher => user
        can :create, Comment
        can [:update, :delete], Comment, :commenter => user
        can :read, User
        can [:update, :delete], User, :asi_id => user.asi_id
      end
    else  # not logged in
      can :create, User
    end
  end
end
