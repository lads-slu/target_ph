#create feedback vector of class character
feedback <- 'Information:'

#do not update map?
if (no.update == T & application == 'clay content') feedback <- c(feedback, 'Uppladdade data uppfyllde inte kraven. Lerhaltskartan uppdaterades inte.')
if (no.update == T & application == 'pH') feedback <- c(feedback, 'Uppladdade data uppfyllde inte kraven. Ingen kalkbehovskarta kunde tas fram.')

#is the lime requirement > 4000 kg / ha?
if (exists('lr.test')) feedback <- c(feedback, 'I hela eller delar av de valda blocken är kalkbehovet större än 4000 kg CaO/ha. Där kan man överväga delad giva. Mer information finns i Jordbruksverkets skrift Rekommendationer för gödsling och kalkning')

#is the MgAL status low?
if (exists('MgAL.feedback')) feedback <- c(feedback, MgAL.feedback)

#How many samples were there in the uploaded file?
feedback <- c(feedback, paste0('Det finns ', uploaded.samples, ' prover i den uppladdade filen.'))

#How many samples are there within the uploaded area?
feedback <- c(feedback, paste0(samples.in.area, ' av proverna i den uppladdade filen ligger inom de valda blocken.'))

#is the average distance between a sample and its nearest naiughtbour too large
if (ok.samples > 0 & sparse == T) feedback <- c(feedback, "Proverna inom de valda blocken ligger för glest (medelavståndet mellan ett prov och dess närmsta grannprov var större än 300 m). ")

#is any column neiter numerical nor logical?
if (non.numeric == T) feedback <- c(feedback, paste0('Någon eller några av de uppladdade kolumnerna innehåller icke-numeriska värden och kunde inte användas'))

#how many samples have values for pH /clay content?
if (application == 'clay content') feedback <- c(feedback, paste0(lab.values, ' av proverna i den uppladdade filen har lerhaltsvärden.'))
if (application == 'pH') feedback <- c(feedback, paste0(lab.values, ' av proverna i den uppladdade filen har pH-värden.'))

#are uploaded values out or range?
if (high.clay > 0) feedback <- c(feedback, paste0(high.clay, ' prov(er) har en lerhalt över 80 %. Kontrollera att det stämmer och överväg att ta bort dessa prov innan du laddar upp filen!'))
if (application == 'pH' & high.som > 0) feedback <- c(feedback, paste0(high.som, ' prov(er) har en mullhalt över 20 %. Dessa har justerats till 20 % i kalkbehovsberäkningen.'))
if (application == 'pH' & out.of.range.pH > 0) feedback <- c(feedback, paste0(out.of.range.pH, ' prov(er) har ett pH-värden under 4,5 eller över 8,5. Kontrollera att det stämmer och överväg att ta bort dessa prov innan du laddar upp filen.'))

#Aare there samples not co vered by dsms (e.g. areas with organic soil)?
if (no.dsms > 0) feedback <- c(feedback, paste0('Det finns ', no.dsms, ' prover inom de valda blocken där DSMS saknar täckning. De har tagits bort.'))

#IS ANY AREA WITHIN THE SELECTED BLOCKS CLASSIFIED AS ORGANIC SOIL?
if (organic.soil > 0 & no.update == F) feedback <- c(feedback, 'Det finns ytor inom de valda blocken som är klassificerade som organiska jordar i DSMS. De har tagits bort.')

#HOW MANY SAMPLES WERE USED?
if (exists('ok.samples') & application == 'clay content' & no.update == F) feedback <- c(feedback, paste0('Totalt användes ', ok.samples, ' prover för att ta fram den lokalt bästa lerhaltskartan.'))
if (exists('ok.samples') & application == 'pH' & no.update == F) feedback <- c(feedback, paste0('Totalt användes ', ok.samples, ' prover för kalkbehovsberäkningen.'))

#is the entire area of the selected blocks updated? 
#if(not.covered & no.update==F & application =='clay content') feedback<-c(feedback,"Proverna täckte inte hela de valda skiftena. Kartan visar lerhalter från DSMS i de områden som inte täcks.")
#if(not.covered & no.update==F & application =='pH') feedback<-c(feedback,"Proverna täckte inte hela de valda skiftena. Därför täcker inte kalkbehovskartan hela ytan.")

#omit title
feedback <- feedback[2:length(feedback)]