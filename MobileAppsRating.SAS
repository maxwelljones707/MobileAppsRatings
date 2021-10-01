*quantitative EDA;
proc sgscatter data=mydata.GOOGLE_PLAYSTORE_DATA;
plot Rating*(Reviews Price);
run;

*take only the E and Teen groups;
data mydata.new_E;
 set mydata.GOOGLE_PLAYSTORE_DATA;
 where Content_Rating = 'E';
 run; 
 
data mydata.new_T;
 set mydata.GOOGLE_PLAYSTORE_DATA;
 where Content_Rating = 'Teen';
 run; 

*Take a sample;
proc surveyselect data= mydata.new_E method=srs n = 100
seed=180 out=mydata.new_sample_E;
strata Content_Rating;
run;

proc surveyselect data= mydata.new_T method=srs n = 100
seed=180 out=mydata.new_sample_Teen;
strata Content_Rating;
run;

*regression;
proc reg data = mydata.combo_new plots=none;
model Rating = log_new_rev log_new_price;
run;

*calculate p-value from f statistic;
data cutoff;
fcritical=quantile("F",.90,6,191);*quantile("F",1-alpha,k-g,n-k-1);
pval=sdf("F",0.71859505548,6,191); *sdf("F",test statistic,k-g,n-k-1);
proc print data=cutoff;
run;

*log transformation;
data mydata.combo_new;
   set mydata.combo;
   if Price = 0 then new_price = .001;
   if Price ~= 0 then new_price = Price;
   if Reviews = 0 then new_rev = .001;
   if Reviews ~= 0 then new_rev = Reviews;
run;

data mydata.combo_new;
   set mydata.combo_new;
   log_new_price = log(new_price);
   log_new_rev = log(new_rev);
run;

*make dummy variable;
data mydata.combo; *original data table;
	set mydata.combo; *set the original data table (add new columns);
	DummyContentB=0; *create a variable called DummyGenreB where every observation will have a value of 0;
	if Content_Rating = 'E' then DummyContentB=1; *similar to above;
run;

data mydata.combo; *original data table;
	set mydata.combo; *set the original data table (add new columns);
	DummyInstallB = 0; *create a variable called DummyGenreB where every observation will have a value of 0;
	DummyInstallC = 0;
	if  Installs = 'under_1_million' then DummyInstallB=1; *similar to above;
	if  Installs = '1_to_10_million' then DummyInstallC=1; *similar to above;
run;

data mydata.combo; *original data table;
	set mydata.combo; *set the original data table (add new columns);
	DummyCatB = 0; *create a variable called DummyGenreB where every observation will have a value of 0;
	DummyCatC = 0;
	DummyCatD = 0;
	if  Category = 'Lifestyle' then DummyCatB=1; *similar to above;
	if  Category = 'Media' then DummyCatC=1; *similar to above;
	if  Category = 'Productiv' then DummyCatD=1; *similar to above;
run;

proc sgplot data= mydata.combo;
	vline Reviews / response=Rating datalabel stat=mean;
	*vline quantitative variable / response = response variable datalabel stat=mean;
	*stat = mean gives the means value of y for each category of the qualitative variable;
Run;

proc sgplot data= mydata.combo;
	vline Category / response=Rating datalabel stat=mean;
	*vline quantitative variable / response = response variable datalabel stat=mean;
	*stat = mean gives the means value of y for each category of the qualitative variable;
Run;

proc sgplot data= mydata.combo;
	vline Installs / response=Rating datalabel stat=mean;
	*vline quantitative variable / response = response variable datalabel stat=mean;
	*stat = mean gives the means value of y for each category of the qualitative variable;
Run;
