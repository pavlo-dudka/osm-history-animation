import java.io.*;
import java.util.*;
import java.util.regex.*;

public class OsmHistorySplitter
{
	public static void main(String[] args)
	{
		String dateMaskLength = "10";
		if (args != null && args.length > 0)
			dateMaskLength = args[0];
		
		HashSet<String> dateHash = new HashSet<String>();
		HashMap<String, StringBuffer> mapObjectsByDate = new HashMap<String, StringBuffer>();
				
		try
		{
			String pattern = ".*<(.*?) id=\"(.*?)\" version=\"(.*?)\" timestamp=\"(.{" + dateMaskLength + "}?).* visible=\"(.*?)\".*";
			Pattern p = Pattern.compile(pattern);

			File historyFile = new File("ukraine.osh");

			BufferedReader in = new BufferedReader(new InputStreamReader(new FileInputStream(historyFile), "UTF8"));

			String currentLine, currentObjectId = null, currentObjectDate = null, currentObjectVisible = null, newObjectDate = null;
			HashMap<String, String> currentOperation = new HashMap<String, String>();
			StringBuffer currentObject = new StringBuffer(1024);
			boolean isNewObject = false;
			
			Integer i = 1;
			while ((currentLine = in.readLine()) != null)
			{
				i++;
					
				if (currentLine.startsWith("node", 3) || currentLine.startsWith("way", 3) || currentLine.startsWith("relation", 3))
				{	
					Matcher m = p.matcher(currentLine);
					if (!m.find())
					{
						System.out.println("ERROR: " + currentLine);
						continue;
					};
					
					String type = m.group(1);
					String id = m.group(2);
					String version = m.group(3);
					String date = m.group(4);
					String visible = m.group(5);
					
					if (currentObjectId == null)
						;
					else if (id.equals(currentObjectId) && date.equals(currentObjectDate))
						currentObject.delete(0, currentObject.length());
					else
					{
						dateHash.add(currentObjectDate);
						
						String operation = "";
						if (isNewObject && currentObjectVisible.equals("false"))
							;
						else if (isNewObject)
							operation = "create";							
						else if (currentObjectVisible.equals("false"))
							operation = "delete";
						else
							operation = "modify";
						
						if (isNewObject && currentObjectVisible.equals("false"))
							;
						else if (currentOperation.get(currentObjectDate) == null)
						{
							StringBuffer sb = new StringBuffer();
							mapObjectsByDate.put(currentObjectDate, sb);
							
							sb = sb.append(" <").append(operation).append(">");
							sb = sb.append(currentObject);
							
							currentOperation.put(currentObjectDate, operation);
						}
						else if (!currentOperation.get(currentObjectDate).equals(operation))
						{
							StringBuffer sb = mapObjectsByDate.get(currentObjectDate);
							sb = sb.append("\n </").append(currentOperation.get(currentObjectDate)).append(">");
							sb = sb.append("\n <").append(operation).append(">");
							sb = sb.append(currentObject);
							
							currentOperation.put(currentObjectDate, operation);
						}
						else
						{
							StringBuffer sb = mapObjectsByDate.get(currentObjectDate);
							sb = sb.append(currentObject);
						}
						
						isNewObject = false;
						currentObject.delete(0, currentObject.length());
					}					
					
					if (version.equals("1"))
					{
						isNewObject = true;
						if (newObjectDate == null || !date.equals(newObjectDate))
						{
							System.out.println(type + " " + date);
							newObjectDate = date;
						}
					}
					
					currentObjectId = id;
					currentObjectDate = date;
					currentObjectVisible = visible;
				}
				
				if (currentObjectId != null)
				{
					currentObject = currentObject.append("\n").append(currentLine);
				}
			}

			String folderName = "osc_2012";
			File dir = new File(folderName);
			dir.mkdir();
			
			List<String> dateList = new ArrayList<String>(dateHash);
			Collections.sort(dateList);
			for (String date : dateList)
			{
				System.out.println("saving " + date);
				
				if (currentOperation.get(date) == null)
					continue;
				
				PrintWriter printWriter = new PrintWriter(folderName + "\\UA-" + date.substring(2).replace("-","") + ".osc", "UTF-8");
				printWriter.println("<?xml version='1.0' encoding='UTF-8'?>");
				printWriter.println("<osmChange version=\"0.6\" generator=\"OSM History Splitter\">");
				printWriter.println(mapObjectsByDate.get(date).toString());
				printWriter.println(" </" + currentOperation.get(date) + ">");
				printWriter.println("</osmChange>");
				printWriter.close();				
			}
			
			in.close();
		}
		catch (UnsupportedEncodingException e) 
		{
			System.out.println(e.getMessage());
		} 
		catch (IOException e) 
		{
			System.out.println(e.getMessage());
		}
		catch (Exception e)
		{
			System.out.println(e.getMessage());
		}		
	}
}