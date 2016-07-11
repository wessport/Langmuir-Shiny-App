# Langmuir Shiny App ReadMe

<head>
<h3>To try out the web app click here: <a href="https://wessport.shinyapps.io/Langmuir-Shiny-App/">Langmuir Web App</a> </h3>
</head>

<body>
<h2>User Guide:</h2>
Visit http://wessport.github.io/Langmuir-Shiny-App/ for the web version of this ReadME.
<br>
<br>
The intention of this app is to facilitate the fitting of sorption data to the <b>Langmuir Equation</b>: 
<br>
<br>
<center><a href="https://www.codecogs.com/eqnedit.php?latex=Re=&space;\frac{k\cdot&space;Qmax&space;\cdot&space;Xf}{1&plus;k&space;\cdot&space;Xf}" target="_blank"><img src="https://latex.codecogs.com/gif.latex?Re=&space;\frac{k\cdot&space;Qmax&space;\cdot&space;Xf}{1&plus;k&space;\cdot&space;Xf}" title="Re= \frac{k\cdot Qmax \cdot Xf}{1+k \cdot Xf}" /></a></center>
<br>
<br>
<b>Where</b><ul> 
<li> RE is the amount of molecule or ion (sorptive) adsorbed or desorbed (mg / kg soil)</li> 
<li> Xf is the final measured equilibrium solution concentration (mg P / L soln)</li> 
<li> Qmax is the maximum sorption capacity (mg P / kg soil)</li>
<li> K is the binding affinity coefficient (L / mg)</li>
(Mayes et al. 2012)</ul>

<br>
To try out an example of the app functionality click the Example Sorption Data box. This will load example Phosphorus sorption data of an Ultisol from Tennessee. 


<img src="https://dl.dropboxusercontent.com/s/vepfhgljlb221kn/Screen%20Shot%202016-07-11%20at%201.png?dl=0" alt="IMAGE 1" style="width:64px;height:64px;">

You can upload your own sorption data by selecting the Choose File input. <b>Maximum file size 5MB</b>. 
<br><b>IMPORTANT:</b> Be sure to signify if your data has headers. The default is Headers = FALSE. 
<br>
<br>
<img src="https://dl.dropboxusercontent.com/s/l8zlgn27u4uq71m/Screen%20Shot%202016-07-11%20at%202.png?dl=0" alt="IMAGE 2" style="width:128px;height:128px;">
<br>
<br>
After uploading your sorption data, or electing to use the example data, a plot of the molecule or ion sorbed to the sorbent (solid sruface) versus the equilibrium concentration of the molecule or ion remaining in solution will be generated.<br>
<br>
<br>
<img src="https://dl.dropboxusercontent.com/s/9yeu4ptp606mi3i/Screen%20Shot%202016-07-11%20at%202.28.02%20PM.png?dl=0" alt="IMAGE 3" style="width:128px;height:128px;">
<br>
<br>
<br> You may then select between 5 separate tab panels that provide you with various information.
  <h3>Tab Panels:</h3>
  <ul>
  <li>Residuals of Fit<ul>
    <br> This tab presents the user with a plot of the residuals of the fit of their sorption data to the Langmuir equation i.e. how well does the curve fit the observed data. This is useful for illustrating which data points are ill-conforming.
    <br><b>NOTE:</b> Do your residuals resemble a "fan-shape"?
    <br><img src="https://dl.dropboxusercontent.com/s/pqirmjti49ywk30/Screen%20Shot%202016-07-11%20at%204.png?dl=0" alt="IMAGE 3" style="width:128px;height:128px;">
    <br>If so, you may want to consider a log-transformation of your dependent varibles. This can be done by returning to the 'plot tab' and selecting the 'log-transform' checkbox underneath your original plot. To learn more about this technique please visit the National Institute of Standards and Technology <a href="http://www.itl.nist.gov/div898/handbook/pri/section2/pri24.htm">Engineering and Statistics Handbook</a>.
      </ul></li>

  
  
  <li>Data<ul>
    <br> A reactive table of the user uploaded data. If log-transform Y-axis is selected on the plot-tab, the data displayed here will reflect that change and vice versa. 
    </ul></li>
    
  <li>Data Summary<ul>
    <br> A summary of the user uploaded data including the Minimum, 1st Quantile, Median,Mean, 3rd Quantile, and Maximum for the "X" column and "Y" column. 
    </ul></li></li>
    <br>
  <li>File Information</li>
  <br>
  <li>App Credits</li>
</ul>

<br>
<br>
<b>Contents of Langmuir App download package include:</b> The source code for the Langmuir Shiny App, a text document of my code scrap book during the app development, the R Studio project file, and the Langmuir Shiny App License. 
<br/>


</body>
