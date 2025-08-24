class ChangeDeviceColumnOfUserUiActionToText < ActiveRecord::Migration
  def change
    change_column :user_ui_actions, :device, :text
  end
end
