class FriendshipsController < ApplicationController
  def create
    @friendship = Friendship.new(friendship_params)
    flash[:notice] = if @friendship.save
                       'Friend request sent.'
                     else
                       'Unable to send friend request.'
                     end
    redirect_to request.referrer
  end

  def update
    requester = User.find params[:user_id]
    flash[:notice] = if current_user.confirm_friend(requester, current_user)
                       'Request accepted!'
                     else
                       'Request denied!'
                     end
    redirect_to request.referrer
  end

  def destroy
    @other_user = User.find params[:id]
    @f_to_del = current_user.requested_friendships.where(requester_id: current_user.id) +
                @other_user.requested_friendships.where(requester_id: @other_user.id)
    @f_to_del.each(&:destroy)
    flash[:notice] = 'Deleted succesfully'
    redirect_to request.referrer
  end

  private

  def friendship_params
    { receiver_id: params[:receiver_id],
      requester_id: params[:requester_id],
      status: params[:status] }
  end
end
