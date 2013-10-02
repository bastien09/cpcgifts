package fr.cpcgifts.task;

import java.io.IOException;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.logging.Logger;

import javax.jdo.PersistenceManager;
import javax.jdo.Query;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.datastore.Cursor;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.taskqueue.Queue;
import com.google.appengine.api.taskqueue.QueueFactory;
import com.google.appengine.api.taskqueue.TaskOptions;
import com.google.appengine.datanucleus.query.JDOCursorHelper;

import fr.cpcgifts.model.Giveaway;
import fr.cpcgifts.persistance.PMF;

@SuppressWarnings("serial")
public class UpdateGAsSet extends HttpServlet {

	private static final Logger log = Logger.getLogger(UpdateGAsSet.class.getName());
	
	private static final int BATCH_SIZE = 100;
	
	public void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {
		PersistenceManager pm = PMF.get().getPersistenceManager();
		
		Query q = pm.newQuery(Giveaway.class);
		
		Cursor cursor = null;
		
		try {
			cursor = Cursor.fromWebSafeString(req.getParameter("cursor"));
		} catch(Exception e) {}
		
		if(cursor != null) {
			log.info("New task with cursor : " + cursor);
			Map<String, Object> extensionMap = new HashMap<String, Object>();
			extensionMap.put(JDOCursorHelper.CURSOR_EXTENSION, cursor);
			q.setExtensions(extensionMap);
		}
		
		q.setRange(0, BATCH_SIZE);
		
		List<Giveaway> gas = (List<Giveaway>) q.execute();
		
		for(Giveaway ga : gas) {
			log.info("Updating ga : " + ga);
			
			Set<Key> comments = new HashSet<Key>(ga.comments);
			ga.setComments(comments);
			log.info("Updated comments.");
			
			Set<Key> entrants = new HashSet<Key>(ga.entrants);
			ga.setEntrants(entrants);
			log.info("Updated entrants.");
			
			pm.makePersistent(ga);
			
			log.info("Giveaway updated.");
		}
		
		cursor = JDOCursorHelper.getCursor(gas);
		
		String cursorString = cursor.toWebSafeString();
		
		pm.close();

		Queue queue = QueueFactory.getQueue("datastore-update");
		if(gas.size() != 0) {
			queue.add(TaskOptions.Builder.withUrl("/task/gaupdate2").param("cursor", cursorString));
		}
		
	}
	
}
