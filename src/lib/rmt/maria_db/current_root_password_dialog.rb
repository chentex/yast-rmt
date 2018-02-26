# Copyright (c) 2018 SUSE LLC.
#  All Rights Reserved.

#  This program is free software; you can redistribute it and/or
#  modify it under the terms of version 2 or 3 of the GNU General
#  Public License as published by the Free Software Foundation.

#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.   See the
#  GNU General Public License for more details.

#  You should have received a copy of the GNU General Public License
#  along with this program; if not, contact SUSE LLC.

#  To contact SUSE about this file by physical or electronic mail,
#  you may find current contact information at www.suse.com

require 'rmt/base'

module RMT; end
module RMT::MariaDB; end

class RMT::MariaDB::CurrentRootPasswordDialog < RMT::Base
  def run
    ret = nil

    UI.OpenDialog(
      VBox(
        VSpacing(1),
        Heading(_('Database root password is required')),
        VSpacing(1),
        HBox(
          HSpacing(2),
          VBox(
            Label(_('Please provide the current database root password.')),
            MinWidth(15, Password(Id(:root_password), _('MariaDB root &password')))
          ),
          HSpacing(2)
        ),
        VSpacing(1),
        HBox(
          PushButton(Id(:cancel), Opt(:key_F9), Label.CancelButton),
          HSpacing(2),
          PushButton(Id(:ok), Opt(:default, :key_F10), Label.OKButton)
        ),
        VSpacing(1)
      )
    )

    UI.SetFocus(Id(:root_password))

    loop do
      user_ret = UI.UserInput

      if user_ret == :cancel
        ret = nil
        break
      elsif user_ret == :ok
        root_password = UI.QueryWidget(Id(:root_password), :Value)

        if !root_password || root_password.empty?
          UI.SetFocus(Id(:root_password))
          Report.Error(_('Please provide the root password.'))
          next
        elsif !root_password_valid?(root_password)
          UI.SetFocus(Id(:root_password))
          Report.Error(_('The provided password is not valid.'))
          next
        end

        ret = root_password
        break
      end
    end

    UI.CloseDialog

    ret
  end

  def root_password_valid?(password)
    run_command(
      "echo 'show databases;' | mysql -u root -p%1 2>/dev/null",
      password
    ) == 0
  end
end