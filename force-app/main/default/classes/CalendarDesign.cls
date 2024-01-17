/**
 * Created on Thu Jun 09 2022
 *
 * Copyright (c) 2022 MJ12358
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 *    are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, 
 *    this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 *    this list of conditions and the following disclaimer in the documentation 
 *    and/or other materials provided with the distribution.
 * - Neither the name of the company, software or the names of its contributors 
 *    may be used to endorse or promote products derived from this software without 
 *    specific prior written permission.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
 *  TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 *  THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, TORT (INCLUDING NEGLIGENCE) OR OTHERWISE, 
 *  ARISING FROM, OUT OF OR IN CONNECTION WITH THE USE OF THIS SOFTWARE OR OTHER DEALINGS IN THE SOFTWARE, 
 *  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 **/

public with sharing class CalendarDesign extends VisualEditor.DynamicPickList {

  private VisualEditor.DynamicPickListRows rows = new VisualEditor.DynamicPickListRows();

  public CalendarDesign(VisualEditor.DesignTimePageContext context) {
    this.rows.addRow(new VisualEditor.DataRow('Current User', 'currentuser'));

    for (Calendar cal : [
      SELECT Id, Name, UserId, Type 
      FROM Calendar 
      WHERE (Type != 'User' OR UserId = :System.UserInfo.getUserId()) AND IsActive = true 
      ORDER BY Name
    ]) {
      if (cal.UserId == System.UserInfo.getUserId()) {
        this.rows.addRow(new VisualEditor.DataRow('My Calendar', String.valueOf(cal.UserId)));
      } else {
        String name = String.isNotBlank(cal.Name) ? cal.Name : cal.Type;
        this.rows.addRow(new VisualEditor.DataRow(name, String.valueOf(cal.Id)));
      }
    }
  }

  public override VisualEditor.DataRow getDefaultValue() {
    return this.rows.get(0);
  }

  public override VisualEditor.DynamicPickListRows getValues() {
    return this.rows;
  }

}
