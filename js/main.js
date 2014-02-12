function setAllCheckBoxes(className, elem)
{

    var CheckValue = elem.checked == true ? 'checked' : '';
    var FormName = 'import';
    var objCheckBoxes = [];
	if(!document.forms[0])
		return;
    for (i=0;i < document.forms[0].elements.length;i++) {
       var cur = document.forms[0].elements[i];
       if(cur.className == className)
            objCheckBoxes.push(cur);
    }
    if(!objCheckBoxes)
		return;
		
	var countCheckBoxes = objCheckBoxes.length;
	if(!countCheckBoxes)
		return;
	else
		// set the check value for all check boxes
		for(var i = 0; i < countCheckBoxes; i++)
			objCheckBoxes[i].checked = CheckValue;
}

jQuery(function() {
  var tmpl = function(string,value) {
       return string.replace(/%[\w]+%/gi,value);
  };
  //Initialize Default State
  $("#export").hide();
  $("#import").hide();
  
  //Navigation Click Handlers
  $("#home-export,#nav-export").click(function(e) {
     e.preventDefault();
     $("#nav-export").addClass("active");
     $("#nav-home").removeClass("active");
     $("#nav-import").removeClass("active");
     $("#export").show();   
     $("#home").hide();
     $("#import").hide();
  });
  $("#home-import,#nav-import").click(function(e) {
     e.preventDefault();
     $("#nav-export").removeClass("active");
     $("#nav-home").removeClass("active");
     $("#nav-import").addClass("active");
     $("#export").hide();   
     $("#home").hide();
     $("#import").show();
  });
  $("#home-home,#nav-home").click(function(e) {
     e.preventDefault();
     $("#nav-export").removeClass("active");
     $("#nav-home").addClass("active");
     $("#nav-import").removeClass("active");
     $("#export").hide();   
     $("#home").show();
     $("#import").hide();
  });
 
  
  //Load Export Configuration
  $.ajax({
     url: "/export-configuration.xqy",
     method:'post',
     dataType:'json',
     success:function(response) {
       $.map(response.databases,function(e) {
          $("#databases").append("<li><div class='controls control-row'><input type='checkbox' name='databases' value='" + e +"'/> "+ e + " </div></li>");
       });       
       $.map(response.forests,function(e) {
          $("#forests").append("<li><div class='controls control-row'><input type='checkbox' name='forests' value='" + e +"'/> "+ e + " </div></li>");
       });
       $.map(response.servers,function(e) {
          $("#servers").append("<li><div class='controls control-row'><input type='checkbox' name='servers' value='" + e +"'/> "+ e + " </div></li>");
       }); 
       $.map(response.roles,function(e) {
          $("#roles").append("<li><div class='controls control-row'><input type='checkbox' name='roles' value='" + e.id +"'/> "+ e.name + " </div></li>");
       });
       $.map(response.users,function(e) {
          $("#users").append("<li><div class='controls control-row'><input type='checkbox' name='users' value='" + e.id +"'/> "+ e.name + " </div></li>");
       });       
     }
  });
    //Initialize Import Wizard
    $('#rootwizard').bootstrapWizard({

        onNext : function(tab,navigation,index) {
           if(index == 1) {
              if(!$("#config-file").val()) {
                alert("Please select a file to import");
                $("#config-file").focus();
                return false;
              } else {
                    var file = $('#config-file').get(0).files[0];
                    var reader = new FileReader();
                    reader.onload = function() {
                       $.ajax({
                          url:'/post-configuration.xqy',
                          type:'PUT',
                          contentType:'text/xml',
                          dataType:'json',
                          data: reader.result,
                          success : function(response){
                            $("#database-config tbody").empty();
                             //Create Databases
                             $.map(response.databases,function(data) {
                               var sop = "<tr>";
                               sop += "<td><b class='btn btn-primary btn-small'>DATABASE</b> " + data.name +"</td>";
                               sop += "<td><input type='checkbox' name='database-include|%name%' value='' checked/></td>";
                               sop += "<td><input type='text' name='database|%name%' value='" + data.id+ "'/></td>";
                               sop += "</tr>"
                               sop = tmpl(sop,data.name);
                               $("#database-config tbody").append(sop);
                            });
                            //Create Forests
                            $("#forest-config tbody").empty();
                             $.map(response.forests,function(data) {
                               var sop = "<tr>";
                               sop += "<td><b class='btn btn-success btn-small'>FOREST</b>  " + data.name +"</td>";
                               sop += "<td><input type='checkbox' name='forest-include|%name%' value='' checked/></td>";
                               sop += "<td><input type='text' name='forest|%name%' value='" + data.id + "'/></td>";
                               sop += "<td><input type='text' name='forest-dir|%name%' value='" + data.dataDir + "'/></td>";
                               sop += "</tr>"
                               sop = tmpl(sop,data.name);
                               $("#forest-config tbody").append(sop);
                            });
                             //Create Servers
                             $("#server-config tbody").empty();
                             $.map(response.servers,function(data) {
    
                               var sop = "<tr>";
                               sop += "<td><b class='btn btn-info btn-small'>" + data.type.toUpperCase() + " </b> "+ data.name +"</td>";
                               sop += "<td><input type='checkbox' name='server-include|%name%' value='' checked/></td>";
                               sop += "<td><input type='text' name='server-port|%name%' value='" + data.port + "'/></td>";
                               sop += "<td><input type='text' name='server|%name%' value='" + data.id+ "'/></td>";
                               sop += "</tr>"
                               sop = tmpl(sop,data.name);
                               $("#server-config tbody").append(sop);
                            });      
                             //Roles
                             $("#role-config tbody").empty();
                             $.map(response.roles,function(data) {
    
                               var sop = "<tr>";
                               sop += "<td><b class='btn btn-warning btn-small'>Role </b> "+ data.id +"</td>";
                               sop += "<td><input type='checkbox' name='role-include|%name%' value='' checked/></td>";
                               sop += "<td> "+ data.name +"</td>";
                               sop += "</tr>"
                               sop = tmpl(sop,data.name);
                               $("#role-config tbody").append(sop);
                            });      
                            //Users
                             $("#user-config tbody").empty();
                             $.map(response.users,function(data) {
    
                               var sop = "<tr>";
                               sop += "<td><b class='btn btn-warning btn-small'>User </b> "+ data.id +"</td>";
                               sop += "<td><input type='checkbox' name='user-include|%name%' value='' checked/></td>";
                               sop += "<td> "+ data.name +"</td>";
                               sop += "</tr>"
                               sop = tmpl(sop,data.name);
                               $("#user-config tbody").append(sop);
                            });                                
                          }
                       });
                    }
                    reader.readAsBinaryString(file);   
                }          
            } else if(index == 2) {
                $(".tab-content").block({message: "<div class='modal hide fade' role='dialog'><div class='row'>Importing configuration ...</div></div>", style : {width:'100%', height:'100%'}});
                var formData = $("#import-config-form").serialize();
                $.ajax({
                  url:"/import-configuration.xqy",
                  data: formData,
                  type:'POST',
                  dataType:'json',
                  success:function(response,state,xhr) {
                    $("#import-results tbody").empty();
                    $.map(response.messages,function(data) {
                        var msgType = data.type == 'error' ? "btn-danger" : 'btn-info';
                        $("#import-results tbody").append("<tr><td><b class='btn " + msgType + " btn-small'>" + data.type  +"</b></td><td>" + data.message +"</td></tr>")   
                    });
                    $('.tab-content').unblock(); 
                  }
                });
            }
        },
        onTabShow: function(tab, navigation, index) {
            var $total = navigation.find('li').length;
            var $current = index+1;
            var $percent = ($current/$total) * 100;
            $("#import-progress .bar").css("width",$percent + "%")
        }});
});