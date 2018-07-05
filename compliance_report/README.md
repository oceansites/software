# compliance_report.py

Running `compliance_report.py` requires [compliance-checker](https://github.com/ioos/compliance-checker)
and beautifulsoup4. 

Configuring your system to execute this code:

1. Install Anaconda Python 3.6 or higher from https://www.anaconda.com/download
2. Clone this repository (You may need to install git. See https://desktop.github.com/):

```
git clone https://github.com/oceansites/software.git
cd software/compliance_report
```

3. Create a Conda environment and install required software:

```
conda create --name compliance_report
source activate compliance_report
conda install -c conda-forge beautifulsoup4 compliance-checker xarray
```

4. Execute the compliance_report for a SITE, e.g.:

```
python compliance_report.py --test cf:1.6 acdd --format summary http://data.nodc.noaa.gov/thredds/catalog/ndbc/oceansites/DATA/MBARI/catalog.xml
```

See [OceanSITES GDAC Dataset Conventions Compliance Report](GDAC_compliance_report.ipynb)
Notebook for example usage.


