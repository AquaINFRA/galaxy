define(["mvc/form/form-view","mvc/ui/ui-misc","utils/query-string-parsing"],function(a,b,c){var d=Backbone.Model.extend({initialize:function(a){a=a||{},a.user_id=a.user_id||Galaxy.user.id,this.set({user_id:a.user_id,information:{title:"Manage information",description:"Edit your email, addresses and custom parameters or change your username.",url:"api/users/"+a.user_id+"/information/inputs",icon:"fa-user",redirect:"user"},password:{title:"Change password",description:"Allows you to change your login credentials.",icon:"fa-unlock-alt",url:"api/users/"+a.user_id+"/password/inputs",submit_title:"Save password",redirect:"user"},communication:{title:"Change communication settings",description:"Enable or disable the communication feature to chat with other users.",url:"api/users/"+a.user_id+"/communication/inputs",icon:"fa-comments-o",redirect:"user"},permissions:{title:"Set dataset permissions for new histories",description:"Grant others default access to newly created histories. Changes made here will only affect histories created after these settings have been stored.",url:"api/users/"+a.user_id+"/permissions/inputs",icon:"fa-users",submit_title:"Save permissions",redirect:"user"},api_key:{title:"Manage API key",description:"Access your current API key or create a new one.",url:"api/users/"+a.user_id+"/api_key/inputs",icon:"fa-key",submit_title:"Create a new key",submit_icon:"fa-check"},toolbox_filters:{title:"Manage Toolbox filters",description:"Customize your Toolbox by displaying or omitting sets of Tools.",url:"api/users/"+a.user_id+"/toolbox_filters/inputs",icon:"fa-filter",submit_title:"Save filters",redirect:"user"},openids:{title:"Manage OpenIDs",description:"Associate OpenIDs with your account.",icon:"fa-openid",onclick:function(){window.location.href=Galaxy.root+"user/openid_manage?cntrller=user&use_panels=True"}},custom_builds:{title:"Manage custom builds",description:"Add or remove custom builds using history datasets.",icon:"fa-cubes",onclick:function(){window.location.href=Galaxy.root+"custom_builds"}},logout:{title:"Sign out",description:"Click here to sign out of all sessions.",icon:"fa-sign-out",onclick:function(){Galaxy.modal.show({title:"Sign out",body:"Do you want to continue and sign out of all active sessions?",buttons:{Cancel:function(){Galaxy.modal.hide()},"Sign out":function(){window.location.href=Galaxy.root+"user/logout?session_csrf_token="+Galaxy.session_csrf_token}}})}}})}}),e=Backbone.View.extend({initialize:function(){this.model=new d,this.setElement("<div/>"),this.render()},render:function(){var a=this,d=Galaxy.config;$.getJSON(Galaxy.root+"api/users/"+Galaxy.user.id,function(e){a.$preferences=$("<div/>").addClass("ui-panel").append($("<h2/>").append("User preferences")).append($("<p/>").append("You are logged in as <strong>"+_.escape(e.email)+"</strong>.")).append(a.$table=$("<table/>").addClass("ui-panel-table"));var f=c.get("message"),g=c.get("status");f&&g&&a.$preferences.prepend(new b.Message({message:f,status:g}).$el),d.use_remote_user||(a._addLink("information"),a._addLink("password")),d.enable_communication_server&&a._addLink("communication"),a._addLink("custom_builds"),a._addLink("permissions"),a._addLink("api_key"),d.has_user_tool_filters&&a._addLink("toolbox_filters"),d.enable_openid&&!d.use_remote_user&&a._addLink("openids"),Galaxy.session_csrf_token&&a._addLink("logout"),a.$preferences.append(a._templateFooter(e)),a.$el.empty().append(a.$preferences)})},_addLink:function(a){var b=this.model.get(a),c=$(this._templateLink(b)),d=c.find("a");b.onclick?d.on("click",function(){b.onclick()}):d.attr("href",Galaxy.root+"user/"+a),this.$table.append(c)},_templateLink:function(a){return'<tr><td><div class="ui-panel-icon fa '+a.icon+'"></td><td><a class="ui-panel-anchor" href="javascript:void(0)">'+a.title+'</a><div class="ui-form-info">'+a.description+"</div></td></tr>"},_templateFooter:function(a){return'<p class="ui-panel-footer">You are using <strong>'+a.nice_total_disk_usage+"</strong> of disk space in this Galaxy instance. "+(Galaxy.config.enable_quotas?"Your disk quota is: <strong>"+a.quota+"</strong>. ":"")+'Is your usage more than expected? See the <a href="https://galaxyproject.org/learn/managing-datasets/" target="_blank">documentation</a> for tips on how to find all of the data in your account.</p>'}});return{View:e,Model:d}});
//# sourceMappingURL=../../../maps/mvc/user/user-preferences.js.map