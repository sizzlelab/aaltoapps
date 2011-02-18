class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here.
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities

    can :read, [Comment, User, Platform]
    cannot :index, [User, Platform]
    can :read, Product, :approval_state => 'published'

    if user  # logged in
      if user.is_admin?

        can :manage, :all                              # admin can do anything
        cannot :update, Comment do |comment|           # except modify others' comments
          comment.commenter != user
        end
        cannot :request_approval, Product do |product| # or request approval for others' apps
          product.publisher != user
        end
        can [:grant_admin_role, :revoke_admin_role], User

      else

        can :read, Product, :publisher_id => user.id
        can :create, Product
        can [:update, :destroy, :add_platform, :request_approval], Product, :publisher_id => user.id
        can :create, Comment
        can [:update, :destroy], Comment, :commenter_id => user.id
        can [:show, :update, :destroy], User, :asi_id => user.asi_id

      end
    else  # not logged in
      can :create, User
    end
  end
end
