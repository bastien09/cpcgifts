package fr.cpcgifts;

import java.io.IOException;
import java.util.Collections;
import java.util.Map;
import java.util.logging.Logger;

import javax.jdo.PersistenceManager;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import net.sf.jsr107cache.Cache;
import net.sf.jsr107cache.CacheException;
import net.sf.jsr107cache.CacheManager;

import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.users.User;
import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;

import fr.cpcgifts.model.Comment;
import fr.cpcgifts.model.CpcUser;
import fr.cpcgifts.model.Giveaway;
import fr.cpcgifts.persistance.PMF;

@SuppressWarnings("serial")
public class EditGAServlet extends HttpServlet {
	
	private static final Logger log = Logger.getLogger(EditGAServlet.class.getName());
	
	public void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {
		
		UserService userService = UserServiceFactory.getUserService();
		User user = userService.getCurrentUser();
		PersistenceManager pm = PMF.get().getPersistenceManager();
		HttpSession session = req.getSession();
		CpcUser cpcuser = (CpcUser) session.getAttribute("cpcuser");
		cpcuser = pm.getObjectById(CpcUser.class, cpcuser.getKey());

		if (user != null && cpcuser != null) {

			@SuppressWarnings("unchecked")
			Map<String, String[]> params = req.getParameterMap();
			
			String gaID = params.get("gaid")[0];
			Giveaway ga = pm.getObjectById(Giveaway.class, KeyFactory.createKey(Giveaway.class.getSimpleName(),Long.parseLong(gaID)));

			String reqType = params.get("req")[0];

			if(reqType.equals("changeimg")) {
				String imgUrl = params.get("imgurl")[0];

				if(cpcuser.getKey().equals(ga.getAuthor())) {
					ga.setImgUrl(imgUrl);
					log.info(cpcuser.getCpcNickname() + ":" + cpcuser.getKey().getId() + " changed giveaway " + ga.getTitle() + "[" + ga.getKey().getId() +  "] image by " + imgUrl);
				}

			} else if(reqType.equals("changedescription")) {
				String newDesc = params.get("desc")[0];

				if(cpcuser.getKey().equals(ga.getAuthor())) {
					ga.setDescription(newDesc);
					log.info(cpcuser.getCpcNickname() + ":" + cpcuser.getKey().getId() + " changed giveaway " + ga.getTitle() + "[" + ga.getKey().getId() +  "] description by " + newDesc);
				}
			} else if(reqType.equals("comment")) {
				String commentText = params.get("comment")[0];
				
				Comment comment = new Comment(cpcuser.getKey(), ga.getKey(), commentText);
				
				pm.makePersistent(comment);
				
				ga.addComment(comment.getKey());
			}
			
			resp.sendRedirect("/giveaway?gaID=" + ga.getKey().getId());
			
			
			try {
	            Cache cache = CacheManager.getInstance().getCacheFactory().createCache(Collections.emptyMap());
	            
	            cache.remove(ga.getKey());
				
	        } catch (CacheException e) {
	        	//rien
	        }
			
		} else {
			resp.sendRedirect("/");
		}
		
		pm.close();
		
	}
}
