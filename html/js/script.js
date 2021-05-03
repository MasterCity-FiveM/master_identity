var myFirstName = document.getElementById('firstname');
var myLastName = document.getElementById('lastname');

$(document).ready(function () {
	$(".UI").hide();
	
	window.addEventListener('message', function(event) {
		if (event.data.type == "enableui") {
			const myVideo = document.getElementById('myVideo');
			if(!event.data.enable)
			{
				$(".UI").hide();
				myVideo.pause()
				myVideo.setAttribute("src", '');	
			}else{
				$.post('https://master_identity/UILoaded', JSON.stringify({}));
				$(".UI").show();
				myVideo.setAttribute("src", 'https://mastercity.ir/files/register.webm');
				myVideo.play()
				myVideo.volume = 0.1;
			}
		}
	});
});

$("#register_btn").click(function(){
	var firstname = $("#firstname").val();
	var lastname = $("#lastname").val();
	if (firstname != '' && lastname != '') {
		$.post('https://master_identity/register', JSON.stringify({
			firstname: $("#firstname").val(),
			lastname: $("#lastname").val(),
			sex: $("input[type='radio'][name='sex']:checked").val()
		}));
	}
});

function isNumber(e) {
	var key=e.which || e.KeyCode;
	if ( key >=48 && key <= 57) {
		return true; 
	}
	else {
		return false;
	}
}

function checkFirstName() {
	var value = myFirstName.value;
	if(value.trim().match(/^[a-zA-Z][0-9a-zA-Z .,'-]*$/) == null) {
		myFirstName.style.backgroundColor = 'rgba(214, 0, 71, 0.9)';
		myFirstName.style.color = '#fff';
	}
	else {
		if(value.length > 0 && value.length < 17) {
			myFirstName.style.backgroundColor = 'rgba(0, 209, 115, 0.9)';
			myFirstName.style.color = '#fff';
		}
		else {
			myFirstName.style.backgroundColor = 'rgba(214, 0, 71, 0.9)';
			myFirstName.style.color = '#fff';
		}
	}
}

function checkLastName() {
	var value = myLastName.value;
	if(value.trim().match(/^[a-zA-Z][0-9a-zA-Z .,'-]*$/) == null) {
		myLastName.style.backgroundColor = 'rgba(214, 0, 71, 0.9)';
		myLastName.style.color = '#fff';
	}
	else {
		if(value.length > 0 && value.length < 17) {
			myLastName.style.backgroundColor = 'rgba(0, 209, 115, 0.9)';
			myLastName.style.color = '#fff';
		}
		else {
			myLastName.style.backgroundColor = 'rgba(214, 0, 71, 0.9)';
			myLastName.style.color = '#fff';
		}
	}
}

function TriggeredKey(e) {
	var keycode;
	if (window.event) keycode = window.event.keyCode;
	if (window.event.keyCode == 13 || window.event.keyCode == 27) return false;
}