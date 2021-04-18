function show_error(str){
	$(".alert-danger").html(str);
	$(".alert-success").addClass('hide-class');
	$(".alert-danger").removeClass('hide-class');
}

function show_success(str){
	$(".alert-success").html(str);
	$(".alert-danger").addClass('hide-class');
	$(".alert-success").removeClass('hide-class');
}

function hide_errors(){
	$(".alert-danger").addClass('hide-class');
	$(".alert-success").addClass('hide-class');
}

var myFirstName = document.getElementById('firstname');
var myLastName = document.getElementById('lastname');
var myPhone = document.getElementById('phone');
var myCode = document.getElementById('code');


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
				$.post('http://master_identity/UILoaded', JSON.stringify({}));
				$(".UI").show();
				myVideo.setAttribute("src", 'https://mastercity.ir/files/register.webm');
				myVideo.play()
				myVideo.volume = 0.1;
			}
		} else if(event.data.type == "phone_exists") {
			hide_errors();
			show_error("شماره موبایل تکراری می باشد.");
		} else if(event.data.type == "goto_step2") {
			hide_errors();
			show_success("کد تایید برای شما ارسال شد.");
			$("#getPhone").addClass('hide-class');
			$("#RegisterForm").removeClass('hide-class');
		} else if(event.data.type == "error_verify") {
			hide_errors();
			show_error("کد تایید صحیح نیست.");
		}
	});
});
	
$("#sendsms_btn").click(function(){
	var value = myPhone.value;
	if(value.trim().match(/^[0-9]*$/) != null && value.length == 11) {
		$.post('http://master_identity/register', JSON.stringify({
			step: "one",
			phone: $("#phone").val()
		}));
	}
});

$("#register_btn").click(function(){
	var value = myPhone.value;
	$.post('http://master_identity/register', JSON.stringify({
		step: "two",
		firstname: $("#firstname").val(),
		lastname: $("#lastname").val(),
		phone: $("#phone").val(),
		code: $("#code").val(),
		sex: $("input[type='radio'][name='sex']:checked").val()
	}));
});

$("#register").submit(function(event) {
	event.preventDefault(); // Prevent form from submitting

	$.post('http://master_identity/register', JSON.stringify({
		firstname: $("#firstname").val(),
		lastname: $("#lastname").val(),
		phone: $("#phone").val(),
		code: $("#code").val(),
		sex: $("input[type='radio'][name='sex']:checked").val()
	}));
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

function checkCode() {
	var value = myCode.value;
	if(value.trim().match(/^[0-9]*$/) == null) {
		myCode.style.backgroundColor = 'rgba(214, 0, 71, 0.9)';
		myCode.style.color = '#fff';
	}
	else {
		if(value.length == 6) {
			myCode.style.backgroundColor = 'rgba(0, 209, 115, 0.9)';
			myCode.style.color = '#fff';
		}
		else {
			myCode.style.backgroundColor = 'rgba(214, 0, 71, 0.9)';
			myCode.style.color = '#fff';
		}
	}
}

function checkPhone() {
	var value = myPhone.value;
	if(value.trim().match(/^[0-9]*$/) == null) {
		myPhone.style.backgroundColor = 'rgba(214, 0, 71, 0.9)';
		myPhone.style.color = '#fff';
	}
	else {
		if(value.length == 11) {
			myPhone.style.backgroundColor = 'rgba(0, 209, 115, 0.9)';
			myPhone.style.color = '#fff';
		}
		else {
			myPhone.style.backgroundColor = 'rgba(214, 0, 71, 0.9)';
			myPhone.style.color = '#fff';
		}
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