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
    border: solid 1px #999999;
    
  }
  
   table.credentials td:nth-child(2) {
       font-size: 9pt;
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
  
</body>
</html>

<#macro header>
<div class="print-header" style="width: 100%;">
    <table style="width: 100%;">
    <tr>
    	<td class="headerName">${resume.name}</td>
    	<td class="headerRight headerEmail"><a href="mailto:${resume.email}">${resume.email}</a></td>

      	<td rowspan="2" width="50"><img height="50" src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAEsAAABLCAYAAAA4TnrqAAABY0lEQVR42u3aQQ7DIAxEUe5/6XSRdRWYsYXBH6mLVmkUXuPUNoyHMT0GBGCBBRZYYIEFAVhggQUWWO8XxpBes+ed/Tz7esDahaUe/++ivyajYrrHg7UL6+s2n30/G27R1wPWLViziGp4gtUVS52Een6wTsVScVfDr3We1QpLLS+y3l9ZG7bCstscJk6rflYrLDX5XG3VrIa1WqCDVQUrKhl1m31q6rHlAQ9WYDPPDUP3R8oIR7B2YKnNPPVB7rZywKqGtXq7r05SxS5ZSIOVWL5kTy4bF6xq/4ZZLZ2oBQ2wqmG5BXVUGZWZIoBVoZ/lpgbRrZuMAhqsE9vKapLrphpgVcPKXgpbLdCjmo5gVcGKCju1bFGbk2CdguVuZota+opMEcA6EStqUTRqkxxYt2C5k4taKgPruXxPqdrMy0QBq2I/K2uLkLsN4OjasAVW5wEWWGCBBRZYDLDAAgsssMBi/ACnZ1edeS78lQAAAABJRU5ErkJggg==" alt="contact ${resume.email}"/></td>
 
    </tr>
    <tr>
    	<td class="headerTitle">${resume.title}<#if (resume.subTitle??)><br/>${resume.subTitle?html}</#if></td><td class="headerRight">${resume.phoneNumber}</td>
    </tr>
    
    </table>
</div>
</#macro>
<#macro daterange start end>
<#if (start = end)>
${start}
<#else>
${start} - ${end}
</#if>

</#macro>
<#macro wordlist list><#assign ct = 0><#list list as item ><#if (ct != 0)>, </#if>${item?html}<#assign ct = ct + 1></#list></#macro>
