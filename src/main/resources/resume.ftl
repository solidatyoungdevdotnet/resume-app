<html>
<head>
  <title>${resume.name}</title>
  <style>
  
  body {
   font-family: Apple Symbols, sans-serif;
   font-size: 10pt;
   
  }
  
  h2 {
            position: relative; /* Establish positioning context */
            text-decoration: none; /* Remove default underline */
            margin-bottom: 0px; /* Add spacing for clarity */
            font-size: 10pt;
        }

        h2::after {
            content: ""; /* Create pseudo-element */
            position: absolute; /* Position relative to the h2 */
            bottom: -3px; /* Position the line below the h2 */
            left: 0; /* Align the line with the start of the h2 */
            width: 100%; /* Span the line across the page */
            border-bottom: 1px solid #999999; /* Style the underline */
        }
        
        
        @media print {
    
    .page-break {
                page-break-before: always;
            }
}

 a {
      text-decoration: none; 
      color: black; 
    }

    
    a:hover {
      color: #555555;
      text-decoration: underline;
    }

p.job  table {
   width: 100%;
}

table {
   veritcal-align: top;
   border-collapse: collapse;
   border-spacing: 0;
   
}



p.job > table > tr > td{
   font-size: 9pt;
   vertical-align: top;
   padding: 0px;
   margin: 0px;
}

p.job > table > tr > td:nth-child(1) {
  width: 20%
}
p.job > table > tr > td:nth-child(2) {
  width: 65%
}
p.job > table > tr > td:nth-child(3) {
  width: 15%
}
p.job {
  font-size: 9pt;
}
p.softwareProjects {
font-size: 9pt;
}

p.focusSkills {
font-size: 9pt;
  vertical-align: top;
}
  		 
p.focusSkills table td {
  vertical-align: top;
  width: 50%;
}

   p.experienceDescription {
   margin-bottom: 0;
   }
   
   td.headerRight {
      text-align:right;
   }
  
  td.headerTitle {
  	font-size: 10.5pt;
  }
  td.headerName {
  	font-size: 12pt;
  	font-weight: bold;
  }
  td.headerName, td.headerEmail {
  	border-bottom: solid 1px #999999;
  }
  
  p.expertise > table > tr > td:nth-child(1) {
   border-right: solid 1px #999999;
  }
  p.expertise > table > tr > td{
     	border-bottom: solid 1px #999999;
  }
  p.expertise > table > tr:nth-child(4) > td {
     	border-bottom: 0px;
  }
  table.credentials {
 
     width: 100%;
  }
  table.credentials td {
    margin: 0;
    padding: 0;
    border: solid 1px #999999;
    
  }
  
   table.credentials td:nth-child(2) {
       font-size: 9pt;
   }
  
  .footer {
        font-size: 8pt;
        position: fixed;
        left: 0;
        bottom: 0;
        width: 100%;
        /*background-color: #333;*/ /* Choose your background color */
        color: #686868;
        text-align: center;
        padding: 10px; /* Add padding for better visibility */
    }
  </style>
</head>
<body>

<@header/>
    <h2>Summary</h2>
    <p>${resume.summary?html}</p>
    <h2>Software Projects</h2>
    <p class="softwareProjects">
    	<#list resume.softwareProjects as proj >
    	 <p><u>${proj.name?html}:</u> ${proj.description?html}
  		</p>	
  			
  		</#list>
  		
    </p>
    <h2>Focus Skills</h2>
    <p  class="focusSkills">
    	<table>
    	<tr>
    		<#list resume.focusSkills as category >
  			<td><u>${category.name?html}:</u>
  			<ul>
  			<#list category.technologies as tech >
  			<li>${tech?html}</li>
  			
  			
  		</#list>
  		</ul>
  		</td>
  		</#list>
    	</tr>
    	</table>
    </p>
    
  
    <div class="page-break"></div>
    <@header/>
    <h2>Professional Experience</h2>
  
  	<#list resume.experience as job >
  		<p class="job">
  		  <b>${job.title}, ${job.companyName} (${job.dates.begin} - ${job.dates.end})</b><br/>
  		  
  		  <#if (job.specialTitle??)>${job.specialTitle?html}<br/></#if>${job.description?html}
  		  <#if (job.projects?size != 0)>
  		  <table>
  		  <#list job.projects as project >
  		  	<tr><td><u>${project.name}:</u></td>
  		  		<td><@wordlist project.technologies/></td>
  		  		<td><@daterange project.dates.begin project.dates.end/></td>
  		  	</tr>
  		  </#list>
  		  </table>
  		  </#if>
  		  
  		</p>
  	</#list>
  	<table class="credentials">
  		<tr><td>Certifications and Education:</td><td>
  		<ul> <#list resume.credentials as item ><li>${item.description} - ${item.year}</li></#list></ul></td></tr>
  	</table>
  	<div class="page-break"></div>
  	<@header/>
  	<h2>Page of Skills</h2>
  	<p class="expertise">
  	<table>
  		<#list resume.skills as category >
  		<tr><td width="25%">${category.name?html}:</td><td><@wordlist category.technologies/></td></tr>
  		</#list>
  	</table>
  	</p>
  
	<footer class="footer">
    	<p>generated using Yodetech resume-app on ${.now?string["yyyy-MM-dd HH:mm:ss"]}</p>
 	</footer>
</body>
</html>

<#macro header>
<header class="print-header" style="width: 100%;">
    <table style="width: 100%;">
    <tr>
    	<td class="headerName">${resume.name}</td>
    	<td class="headerRight headerEmail"><#if (resume.email)?has_content><a href="mailto:${resume.email}">${resume.email}</a></#if></td>
<#if (resume.email)?has_content>
		
      	<td rowspan="2" width="50">
			<img height="50" src="data:image/png;base64,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" alt="contact ${resume.email}"/>

		</td>
      	
 </#if>
    </tr>
    <tr>
    	<td class="headerTitle">${resume.title}<#if (resume.subTitle??)><br/>${resume.subTitle?html}</#if></td>
    	<td class="headerRight">${resume.phoneNumber!""}</td>
    </tr>
    
    </table>
</header>
</#macro>
<#macro daterange start end>
<#if (start = end)>
${start}
<#else>
${start} - ${end}
</#if>

</#macro>
<#macro wordlist list><#assign ct = 0><#list list as item ><#if (ct != 0)>, </#if>${item?html}<#assign ct = ct + 1></#list></#macro>
