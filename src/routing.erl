-module(routing).

-export([routes/0]).

routes() ->
% Host1 = {"/", site_root_handler, []},
Host2 = {"/sample", sample_auth, []},
Host3 = {"/Lycos/auth/lycLogin", login_handler, []}, 
Host4 = {"/Lycos/auth/lycReg", registration_handler, []}, 
Host5 = {"/Lycos/auth/checkPhone", checkphone_handler, []}, 
Host6 = {"/Lycos/auth/updatePhone", updatephone_handler, []}, 
Host7 = {"/Lycos/history/sendMessage", message_send_handler, []}, 
Host8 = {"/Lycos/history/getHistory", message_history_handler, []}, 
Host9 = {"/Lycos/history/updateMsgStatus", message_update_handler, []}, 
Host10 = {"/Lycos/contacts/searchContact", search_contact_handler, []}, 
Host11 = {"/Lycos/contacts/addContact", add_contact_handler, []}, 
Host12 = {"/Lycos/contacts/updateContact", update_contact_handler, []}, 
Host13 = {"/Lycos/fileUpload", upload_file_handler, []}, 

Routes = [Host2, Host3, Host4, Host5, Host6, Host7, Host8, Host9, Host10, Host11, Host12, Host13],
[{'_',Routes}].  
