# DECISION: Clearing a slot has its own controller and a server-side delete.
#   Rejected: an OutfitsController action (it is near the ClassLength limit; a nested resource is plain REST).
#   Rejected: clearing in JS (the chat reads the saved outfit items, and radio buttons can't be unselected cleanly).
class OutfitSlotsController < ApplicationController
  def destroy
    @outfit = policy_scope(Outfit).find(params[:outfit_id])
    authorize @outfit, :clear_slot?
    return redirect_to edit_outfit_path(@outfit), alert: "Unknown slot." unless Outfit::SLOTS.include?(params[:slot])

    @outfit.outfit_items.where(slot: params[:slot]).destroy_all
    redirect_to edit_outfit_path(@outfit, item_id: params[:item_id].presence), status: :see_other
  end
end
