$(function() {
	window.addEventListener('message', function(event) {
		if (event.data.type == "enableui") {
			document.body.style.display = event.data.enable ? "block" : "none";

			const myVideo = document.getElementById('myVideo');

			if(!event.data.enable)
			{
				myVideo.pause()
				myVideo.setAttribute("src", '');	
			}else{
				myVideo.setAttribute("src", 'https://mastercity.ir/files/register.webm');
				myVideo.play()
				myVideo.volume = 0.1;
			}
			
		}
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
});
