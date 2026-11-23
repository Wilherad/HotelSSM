<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!doctype html>
<html lang="zh">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<meta name="Author" content="万林酒店">
	<meta name="Keywords" content="酒店管理系统">
	<meta name="Description" content="酒店管理系统">
	<title>万林酒店|酒店管理系统登录页面</title>
	<link href="../resources/home/css/index.css" type="text/css" rel="Stylesheet" />
	<link href="../resources/home/css/login.css" type="text/css" rel="Stylesheet" />
</head>
<body>

<header>
	<div>
		<a href="index.html">
			<img src="../resources/home/images/logo-3.jpg" alt="万林酒店">
		</a>
		<span>会员登录</span>
	</div>
</header>

<section>
	<div class="left">
		<img src="../resources/home/images/index.png" alt="">
	</div>

	<div class="login">
		<div id="normal">
			<ul id="nor_log">
				<li class="name" style="margin-top:20px;">
					<input id="name" name="uname" type="text" placeholder="请输入用户名">
					<span class="icon"></span>
				</li>
				<li class="pwd" style="margin-top:20px;">
					<input id="password" name="upwd" type="password" placeholder="密码">
					<span class="icon"></span>
				</li>
			</ul>

			<div class="codes" style="margin-top:20px;">
				<input id="vcode" maxlength="4" type="text" class="blur" placeholder="请输入验证码"/>
				<img id="cpacha-img"
					 src="../system/get_cpacha?vl=4&w=120&h=36&type=accountLoginCpacha"
					 onclick="changeVcode()" class="code"
					 style="cursor:pointer; max-width:100%; height:auto;"/>
			</div>
		</div>

		<div class="log" id="bt_login" style="margin-top:20px;cursor:pointer;">登 录</div>
	</div>

	<div class="reg">
		<a href="reg">立即注册 &gt;&gt;</a>
	</div>
</section>

<%@include file="../common/footer.jsp"%>

<script src="../resources/home/js/jquery-1.11.3.js"></script>
<script>
	// 验证码刷新（图片尺寸与上面 src 保持一致，加时间戳防缓存）
	function changeVcode() {
		$("#cpacha-img").attr("src",
				'../system/get_cpacha?vl=4&w=120&h=36&type=accountLoginCpacha&t=' + new Date().getTime());
	}

	$(document).ready(function () {
		// 点击登录：校验 + 异步提交
		$("#bt_login").click(function () {
			var name     = $("#name").val().trim();
			var password = $("#password").val().trim();
			var vcode    = $("#vcode").val().trim();

			if (name === '' || password === '' || vcode === '') {
				alert('请填写完成信息再提交!');
				return;
			}

			$.ajax({
				url: 'login',
				type: 'post',
				dataType: 'json',
				data: { name: name, password: password, vcode: vcode },
				success: function (data) {
					if (data.type == 'success') {
						window.location.href = 'index';
					} else {
						alert(data.msg);
						changeVcode();          // 登录失败时刷新验证码
						$("#vcode").val('');    // 清空验证码输入，避免用户误用旧值
					}
				},
				error: function () {
					alert('网络异常，登录请求失败，请重试。');
					changeVcode();
				}
			});
		});

		// 回车快捷登录（提升手机/电脑体验）
		$("#name, #password, #vcode").keydown(function (e) {
			if (e.keyCode === 13) { $("#bt_login").click(); }
		});
	});
</script>
</body>
</html>


