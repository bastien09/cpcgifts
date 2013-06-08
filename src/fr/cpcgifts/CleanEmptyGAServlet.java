package fr.cpcgifts;

import java.io.IOException;
import java.util.Collections;
import java.util.List;
import java.util.logging.Logger;

import javax.jdo.PersistenceManager;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.sf.jsr107cache.Cache;
import net.sf.jsr107cache.CacheException;
import net.sf.jsr107cache.CacheManager;

import fr.cpcgifts.model.CpcUser;
import fr.cpcgifts.model.Giveaway;
import fr.cpcgifts.persistance.CpcUserPersistance;
import fr.cpcgifts.persistance.GAPersistance;
import fr.cpcgifts.persistance.PMF;

@SuppressWarnings("serial")
public class CleanEmptyGAServlet extends HttpServlet {

	private static final Logger log = Logger.getLogger(CleanEmptyGAServlet.class.getName());
	
	public void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {
		Cache cache;

        try {
            cache = CacheManager.getInstance().getCacheFactory().createCache(Collections.emptyMap());
            cache.clear();
        } catch (CacheException e) {
            log.warning("Cache error : " + e.getMessage());
        }
		
		
		List<Giveaway> gas = GAPersistance.getClosedEmptyGAs(true);
		
		PersistenceManager pm = PMF.get().getPersistenceManager();
		
		for(Giveaway ga : gas) {
			
			CpcUser author = CpcUserPersistance.getCpcUserUndetached(ga.getAuthor());
			
			author.removeGiveaway(ga.getKey());
			
			pm.deletePersistent(ga);
			
			log.info("Giveaway " + ga.getTitle() + " [" + ga.getKey().getId() + "] by " + author.getCpcNickname() + " [" + author.getKey().getId() + "] has been cleaned up.");
		}
		
		CpcUserPersistance.closePm();
		GAPersistance.closePm();
		
	}
	
	
}
