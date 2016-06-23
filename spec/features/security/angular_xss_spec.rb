#-- copyright
# OpenProject is a project management system.
# Copyright (C) 2012-2015 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

require 'spec_helper'

describe 'Angular expression escaping', type: :feature do
  let(:login_field) { find('#username') }

  before do
    visit signin_path
    within('#login-form') do
      fill_in('username', with: login_string)
      click_link_or_button I18n.t(:button_login)
    end

    expect(current_path).to eq signin_path
  end

  describe 'Simple expression' do
    let(:login_string) { '{{ 3 + 5 }}' }

    it 'does not evaluate the expression' do
      expect(login_field.value).to eq('{{ DOUBLE_LEFT_CURLY_BRACE }} 3 + 5 }}')
    end
  end

  context 'With JavaScript evaluation', js: true do
    describe 'Simple expression' do
      let(:login_string) { '{{ 3 + 5 }}' }

      it 'does not evaluate the expression' do
        expect(login_field.value).to eq(login_string)
      end
    end

    describe 'Angular 1.3 Sandbox evading' do
      let(:login_string) { "{{'a'.constructor.prototype.charAt=[].join;$eval('x=alert(1)'); }" }

      it 'does not evaluate the expression' do
        expect(login_field.value).to eq(login_string)
        expect { page.driver.browser.switch_to.alert }
          .to raise_error(::Selenium::WebDriver::Error::NoAlertPresentError)
      end
    end
  end
end