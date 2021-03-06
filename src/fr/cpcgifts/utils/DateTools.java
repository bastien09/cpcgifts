package fr.cpcgifts.utils;

import java.util.Calendar;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.List;

import fr.cpcgifts.model.Comment;
import fr.cpcgifts.model.Giveaway;

public class DateTools {
	
	public static String dateDifference(Date d1, Date d2) {
		
		long diff = 0;
		
		if(d1.getTime() < d2.getTime())
			 diff = d2.getTime() - d1.getTime();
		else
			diff = d1.getTime() - d2.getTime();
		
		long diffSeconds = diff / 1000 % 60;
		long diffMinutes = diff / (60 * 1000) % 60;
		long diffHours = diff / (60 * 60 * 1000) % 24;
		long diffDays = diff / (24 * 60 * 60 * 1000);
		
		if(diffDays > 1) // 1 j ou plus
			return diffDays + " jours";
		if(diffDays == 1)
			return "1 jour et " + diffHours + " heures";
		if(diffHours > 1) // moins d'1 j et plus d'1 h
			return diffHours + " heures et " + diffMinutes + " minutes";
		if(diffHours == 1)
			return "1 heure et " + diffMinutes + " minutes";
		if(diffMinutes > 1)
			return diffMinutes + " minutes";
		if(diffMinutes == 1)
			return "1 minute et " + diffSeconds + " secondes";
		
		return diffSeconds + " secondes";
		
	}
	
	public static String dateDifference(Date d) {
		Calendar c = Calendar.getInstance();
		
		return dateDifference(c.getTime(), d);
	}
	
	public static List<Giveaway> sortGiveawaysByEndDate(List<Giveaway> unsortedList) {
		
		Collections.sort(unsortedList, new Comparator<Giveaway>() {
			public int compare(Giveaway g1, Giveaway g2) {
				return -g1.getEndDate().compareTo(g2.getEndDate());
			}
		});
		
		return unsortedList;
	}
	
	public static List<Comment> sortCommentsByDate(List<Comment> unsortedList) {

		Collections.sort(unsortedList, new Comparator<Comment>() {
			public int compare(Comment c1, Comment c2) {
				return c1.getCommentDate().compareTo(c2.getCommentDate());
			}
		});

		return unsortedList;
	}

}
