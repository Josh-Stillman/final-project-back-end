# Follow → Your → $ README
"Follow → Your → $" compares users’ credit card transactions with campaign-finance data, and shows users how much money the businesses they shop at donate to Republicans and Democrats.  It allows users to visualize where their money is going through animated, annotated, and zoomable charts, as well as sortable tables.

## Description
After a user creates an account on Follow → Your → $, she can upload a .csv file of her recent credit card and bank transactions, exported from her Mint.com account.  The user can then have the app analyze a month of transactions at a time.  After the transactions have been analyzed, the home page will display some top-level data regarding the user's spending, and where the businesses she shops at donate politically.  The user can also:

#### View Transactions  
This view shows all analyzed transaction for which matches were found in OpenSecrets.org's campaign finance database, and basic data about the business for that transaction.  The chart is fully sortable.

#### View Businesses
This view shows all the businesses for which matches were found in the campaign finance database.  It shows the total amount they have given to Republicans and Democrats in the 2016-18 cycles, the percentage of money given to each party, and the total amount of money that the user has spent at that businesses over all analyzed transactions.  The chart is fully sortable.

##### Details
From either the transactions or businesses view, clicking on the name of the business will bring the user to the details view.  Here, they can see each transaction associated with the business.  If there appears to be a mismatch between the transactions and the business found in the campaign finance database, the user can tag those transactions as unmatched or associate those transactions with a new business (feature coming soon).

#### Analytics
This view allows the user to visualize where their money is going.  The default view displays the amount given to the party on the X axis, and the percentage given to that party on the Y axis.  The size of the bubble is the user's spending at that business.  The party can be toggled between Republicans and Democrats.  Take a look -- some more ideological businesses will go flying across the graph when the party is toggled, while businesses that give evenly to both parties will barely budge.  The bubbles' color denotes whether that business's giving leans Democrat, Republican, or Gives to Both.  

The secondary view shows the user's spending at the business on the X axis, the percent the business gives to the party on the Y axis, and the size of each bubble is the amount the business has donated to the party.  Again, the party can be toggled between Republicans and Democrats via the button below the chart.

The chart is fully zoomable, animated, and features a tooltip for each business with relevant data.

### Featuring
* A Ruby on Rails API backend on a PostgreSQL Database, and a React frontend.
* Use of two external APIs and website scraping with Nokogiri to match user's transactions to businesses in the campaign finance database (read more below).  
* Animated, annotated, zoomable charts built using the Victory charting library.
* Extensive user of custom serializers
* Routes developed using React Router
* State Managed with Redux Store
* Authorization and Authentication using bcrypt and jwt
* Semantic UI React used for styling

Here is a brief explanation of how transaction are matched with businesses in the campaign finance database in the app's back end:  After doing some pre-formatting of the business name on the .csv of transactions, first, OpenSecrets.org's name lookup API is queried.  If there is more than one match, the tie is broken by querying a Google Custom Search API that searches the OpenSecrets.org website, and taking the top result.  Last, after a match has been made, the campaign finance data must be scraped using Nokogiri.  

Check out the demo hosted on Heroku: https://follow-your-money.herokuapp.com/

## Contributor's Guide
Please submit any bugs you find or any feature suggestions through the repo.
