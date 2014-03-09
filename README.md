# Interactive Data Visualization Examples

This project contains several examples of simple interactive data visualizations created with [d3.js](http://d3js.org).

View the [data visualization demos](http://mountaintrackapps.com/data_viz/index.html)

View the [notes from the March 12 2014 Philly Data meetup presentation](http://mountaintrackapps.com/data_viz/meetup_notes.html)

## Running and Building

The code is run and built using the static site generator [Middleman](http://middlemanapp.com). See that site for instructions on how to install.

### Run locally

Once Middleman is installed, change to the project directory. Run `bundle` if needed to install the necessary gems on your system.
Then run

    rake preview

Point browser to <http://localhost:4569/index.html> for local testing.

### Build the assets

    rake build

This compiles the `.html`, `.css`, and `.js` assets and copies them to the `build` folder.

## Data

American time use survey data downloaded from [BLS TUS data](http://www.bls.gov/tus/tables/a3_0711.htm) page

Life expectancy fertility rate data downloaded from [World Bank data download site](http://databank.worldbank.org/Data/Views/VariableSelection/SelectVariables.aspx?source=Health%20Nutrition%20and%20Population%20Statistics#)

Rake tasks are used to convert the raw data in the `data` folder into `.json` data files:
    
    rake create_american_time_use_survey_json
    rake create_life_expectancy_json

## Questions?

Please contact Mike Stubna: `mike@stubna.com`