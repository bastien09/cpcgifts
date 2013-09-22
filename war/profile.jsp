<%@page import="fr.cpcgifts.utils.DateTools"%>
<%@page import="java.util.Collection"%>
<%@page import="org.apache.commons.collections.CollectionUtils"%>
<%@page import="java.util.Map"%>
<%@page import="net.sf.jsr107cache.CacheException"%>
<%@page import="java.util.Collections"%>
<%@page import="net.sf.jsr107cache.CacheManager"%>
<%@page import="net.sf.jsr107cache.Cache"%>
<%@page import="java.util.List"%>
<%@page import="fr.cpcgifts.persistance.GAPersistance"%>
<%@page import="fr.cpcgifts.utils.ViewTools"%>
<%@page import="fr.cpcgifts.model.Giveaway"%>
<%@page import="com.google.appengine.api.datastore.KeyFactory"%>
<%@page import="com.google.appengine.api.datastore.Key"%>
<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ page import="com.google.appengine.api.users.User"%>
<%@ page import="com.google.appengine.api.users.UserService"%>
<%@ page import="com.google.appengine.api.users.UserServiceFactory"%>

<%
	UserService userService = UserServiceFactory.getUserService();
	User user = userService.getCurrentUser();
%>

<%
	Cache cache;
	CpcUser profileCpcUser = null;

	String suid = request.getParameter("userID");

	if (suid != null) {
		Long uid = Long.parseLong(suid);

		if (uid != null) {
			Key k = KeyFactory.createKey("CpcUser", uid);
			
			try {
	            cache = CacheManager.getInstance().getCacheFactory().createCache(Collections.emptyMap());
	                        
	            profileCpcUser = (CpcUser) cache.get(k);
	            
				
				if(profileCpcUser == null) {
					profileCpcUser = CpcUserPersistance.getCpcUserUndetached(k);
					cache.put(k, profileCpcUser);
				}
				
	        } catch (CacheException e) {
	        	profileCpcUser = CpcUserPersistance.getCpcUserUndetached(k);
	        }
			
		}
	}

	if (profileCpcUser == null) {
		response.sendRedirect("/404.html");
		return;
	}
%>

<!DOCTYPE html>
<!--[if lt IE 7]>      <html class="no-js lt-ie9 lt-ie8 lt-ie7"> <![endif]-->
<!--[if IE 7]>         <html class="no-js lt-ie9 lt-ie8"> <![endif]-->
<!--[if IE 8]>         <html class="no-js lt-ie9"> <![endif]-->
<!--[if gt IE 8]><!-->
<html class="no-js">
<!--<![endif]-->
<head>
<meta charset="utf-8">
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
<title>Profil de <%=profileCpcUser.getCpcNickname()%> - CPCGifts
</title>
<meta name="description" content="">
<meta name="viewport" content="width=device-width">

<link rel="stylesheet" href="css/bootstrap.min.css">
<style>
body {
	padding-top: 60px;
	padding-bottom: 40px;
}
</style>
<link rel="stylesheet" href="css/bootstrap-responsive.min.css">
<link rel="stylesheet" href="css/main.css">

<script src="js/vendor/modernizr-2.6.2.min.js"></script>
</head>
<body>
	<!--[if lt IE 7]>
            <p class="chromeframe">You are using an <strong>outdated</strong> browser. Please <a href="http://browsehappy.com/">upgrade your browser</a> or <a href="http://www.google.com/chromeframe/?redirect=true">activate Google Chrome Frame</a> to improve your experience.</p>
        <![endif]-->

	<!-- This code is taken from http://twitter.github.com/bootstrap/examples/hero.html -->

	<%@ include file="menubar.jspf"%>
	<%@ include file="getuser.jspf"%>

	<%
		boolean isCurrentUser = userService.isUserLoggedIn() && profileCpcUser.getKey().equals(cpcuser.getKey());
	%>

	<div class="container">


		<div class="row">
			<div class="span3">
				<img src="<%=profileCpcUser.getAvatarUrl()%>" />
				<%
					if(isCurrentUser) {
				%>
				<div class="row" style="margin-top: 10px;">
					<a class="btn btn-success span2" href="#modif-image"
						data-toggle="modal"> <i class="icon-pencil icon-white"></i>
						Modifier l'avatar
					</a>
				</div>
				<%
					}
				%>
			</div>
			<div class="span8">
				<div class="row">
					<h1><%=profileCpcUser.getCpcNickname()%></h1>
				</div>
				<div class="row">
					<% if(profileCpcUser.isBanned()) { %>
						<div class="alert alert-error">Utilisateur banni !</div>
					<% } else { %>
						<a class="btn"
							href="http://forum.canardpc.com/members/<%=profileCpcUser.getCpcProfileId()%>">
							<i class="icon-user"></i> Voir le profil CPC
						</a> <a class="btn"
							href="http://forum.canardpc.com/private.php?do=newpm&u=<%=profileCpcUser.getCpcProfileId()%>">
							<i class="icon-envelope"></i> Envoyer un message privé
						</a>
					<% } %>
				</div>
			</div>
		</div>
		<hr />

		<div class="tabbable">
			<ul class="nav nav-tabs">
				<li id="created-button" class="active"><a
					onclick="javascript:changeSection('#created');" href="#created">Concours
						créés <span class="gray">(<%= profileCpcUser.getGiveaways().size() %>)</span></a></li>
				<li id="entries-button"><a
					onclick="javascript:changeSection('#entries');" href="#entries">Participations <span class="gray">(<%= profileCpcUser.getEntries().size() %>)</span></a></li>
				<li id="won-button"><a
					onclick="javascript:changeSection('#won');" href="#won">Concours gagnés <span class="gray">(<%= profileCpcUser.getWon().size() %>)</span></a></li>
				<% 
					if(userService.isUserLoggedIn() && userService.isUserAdmin()) {
				%>
					<li><a 
					onclick="javascript:changeSection('#admin');" href="#admin" data-toggle="tab">Admin</a></li>
				<%
					}
				%>	
			</ul>

			<div class="tab-content">
				<div id="created" class="tab-pane">
					<%
					Map<Key,Giveaway> gas = null;
					
					try {
						cache = CacheManager.getInstance().getCacheFactory().createCache(Collections.emptyMap());
						
						gas = cache.getAll(profileCpcUser.getGiveaways());
						
						Collection<Key> notCachedKeys = CollectionUtils.subtract(profileCpcUser.getGiveaways(),gas.keySet());
						
						for(Key k : notCachedKeys) {
							Giveaway ga = GAPersistance.getGA(k);
							gas.put(k, ga);
							cache.put(k, ga);
						}
						
					} catch (CacheException e) {
						
					}
					
						for(Giveaway ga : DateTools.sortGiveawaysByEndDate(gas)) {
					%>
		
					<%=ViewTools.gaView(ga)%>
					<hr>
					<%
						}
					%>
				</div>
		
				<div id="entries" class="tab-pane" style="display: none">
		
					<%
					
					Map<Key,Giveaway> entries = null;
					
					try {
						cache = CacheManager.getInstance().getCacheFactory().createCache(Collections.emptyMap());
						
						entries = cache.getAll(profileCpcUser.getEntries());
						
						Collection<Key> notCachedKeys = CollectionUtils.subtract(profileCpcUser.getEntries(),entries.keySet());
						
						for(Key k : notCachedKeys) {
							Giveaway ga = GAPersistance.getGA(k);
							entries.put(k, ga);
							cache.put(k, ga);
						}
						
					} catch (CacheException e) {
						
					}
						
													
					for(Giveaway ga : DateTools.sortGiveawaysByEndDate(entries)) {
					%>
					<%=ViewTools.gaView(ga)%>
					<hr>
					<%
						}
					%>
		
				</div>
		
				<div id="won" class="tab-pane" style="display: none">
		
					<%
					Map<Key,Giveaway> won = null;
					
					try {
						cache = CacheManager.getInstance().getCacheFactory().createCache(Collections.emptyMap());
						
						won = cache.getAll(profileCpcUser.getWon());
						
						Collection<Key> notCachedKeys = CollectionUtils.subtract(profileCpcUser.getWon(),won.keySet());
						
						for(Key k : notCachedKeys) {
							Giveaway ga = GAPersistance.getGA(k);
							won.put(k, ga);
							cache.put(k, ga);
						}
						
					} catch (CacheException e) {
						
					}
					
													
					for(Giveaway ga : DateTools.sortGiveawaysByEndDate(won)) {
					%>
					<%=ViewTools.gaView(ga)%>
					<hr>
					<%
						}
					%>
		
				</div>
				
				<% if(userService.isUserLoggedIn() && userService.isUserAdmin()) { %>
					<div class="tab-pane" id="admin">
						<div class="row offset1">
							<% if(profileCpcUser.isBanned()) { %>
								<a	href="/admin/unbanuser?reqtype=unbanuser&userid=<%= profileCpcUser.getKey().getId() %>"
										class="btn btn-warning"><i class="icon-repeat icon-white"></i> Lever le ban</a>
							<% } else { %>
								<a	href="/admin/banuser?reqtype=banuser&userid=<%= profileCpcUser.getKey().getId() %>"
										class="btn btn-danger"><i class="icon-minus-sign icon-white"></i> Bannir l'utilisateur</a>
							<% } %>
						</div>
						<hr />
					</div>
				<% } %>
				
			</div>
				
		</div>
				

		

		<%@ include file="footer.jspf"%>

	</div>
	<!-- /container -->

	<div id="modif-image" class="modal hide fade">
		<div class="modal-header">
			<button type="button" class="close" data-dismiss="modal"
				aria-hidden="true">&times;</button>
			<h3>Modifier l'avatar</h3>
		</div>
		<div class="modal-body">
			<form id="imgform" name="imgform" action="/changeimg">
				<fieldset>
					<label>Url de l'avatar (184x184 pixels)</label> <input id="imgurl"
						name="imgurl" type="text" placeholder="url" required="required">
					<span class="help-block">Astuce : copiez l'url de votre
						avatar steam, elle est déjà au bon format !</span>
				</fieldset>
			</form>
		</div>
		<div class="modal-footer">
			<a href="#" class="btn" data-dismiss="modal">Annuler</a> <a
				href="javascript:submitImgForm()" class="btn btn-primary">Modifier</a>
		</div>
	</div>

	<script type="text/javascript">
		function submitImgForm() {
			if ($("#imgurl").val() != "") {
				$("#imgform").submit();
			}
		}
	</script>

	<%@ include file="jscripts.jspf" %>
	
	<script type="text/javascript">
		var changeSection = function(sectionName) {
			if (sectionName != "") {
				$('.nav > li').removeClass("active");
				$("#created, #entries, #won, #admin").hide();

				$(sectionName + '-button').addClass("active");
				$(sectionName).show();

			} else {
				changeSection("#created");
			}
		}

		changeSection(window.location.hash);
	</script>

</body>
</html>


<%
	CpcUserPersistance.closePm();
%>