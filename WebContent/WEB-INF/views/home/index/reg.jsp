<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!doctype html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="Author" content="酒店预订">
    <meta name="Keywords" content="酒店预订酒店管理系统">
    <meta name="Description" content="酒店预订酒店管理系统">
    <title>万林酒店|酒店管理系统注册页面</title>
    <link href="../resources/home/css/login.css" type="text/css" rel="Stylesheet" />
    <link href="../resources/home/css/regsiter.css" type="text/css" rel="Stylesheet" />
    <link href="../resources/home/css/index.css" type="text/css" rel="Stylesheet" />
</head>
<body>
<!-- 头部 -->
<header>
    <div>
        <a href=""><img src="../resources/home/images/logo-1.jpg" alt="logo"></a> <span>注册</span>
    </div>
</header>

<!-- 中间部分 -->
<div id="reg">
    <div class="msg">
        <!-- 注册表单 -->
        <div class="panel">
            <form id="user_info" autocomplete="off">
                <div class="form-group">
                    <label for="uname">用户名：</label>
                    <input required minlength="3" maxlength="9" type="text" placeholder="请输入用户名" autofocus name="name" id="uname"/>
                    <span class="msg-default">用户名长度在3到9位之间</span>
                </div>
                <div class="form-group">
                    <label for="upwd">密码：</label>
                    <input required type="password" minlength="6" maxlength="12" placeholder="请输入密码" name="password" id="upwd"/>
                    <span class="msg-default hidden">密码长度在6到12位之间</span>
                </div>
                <div class="form-group">
                    <label for="upwd2">确认密码：</label>
                    <input required type="password" placeholder="再次输入密码" id="upwd2"/>
                    <span class="msg-default hidden">两次密码需一致</span>
                </div>
                <div class="form-group">
                    <label for="uphone">手机：</label>
                    <input required type="tel" placeholder="请输入手机号码" name="mobile" maxlength="11" id="uphone"/>
                    <span class="msg-default hidden">请输入合法的手机号码</span>
                </div>
                <div class="form-group btn-group">
                    <label></label>
                    <input type="button" value="提交注册信息" id="btn_reg"/>
                </div>
            </form>
        </div>

        <!-- 广告与登录跳转 -->
        <div id="ad">
            <div class="login">已有账号，去 <a href="login">登录</a></div>
            <ul id="trigger">
                <li><img src="../resources/home/images/new1.png" alt="轮播图"></li>
            </ul>
        </div>
    </div>
</div>

<%@include file="../common/footer.jsp"%>

<script src="../resources/home/js/jquery-1.11.3.js"></script>
<script>
    /* 用统一校验状态对象，避免单一变量被后一个字段覆盖 */
    var valid = { uname:false, upwd:false, upwd2:false, uphone:false };
    function allValid(){ return valid.uname && valid.upwd && valid.upwd2 && valid.uphone; }

    // 封装提示消息显示函数
    function setMsg(input, text, type){
        var span = input.nextElementSibling;
        if(!span) return;
        span.innerHTML = text;
        span.className = 'msg-' + type;
    }

    /* 1. 对用户名进行验证 */
    uname.onblur = function(){
        if(this.validity.valueMissing){
            setMsg(this,'用户名不能为空','error');
            this.setCustomValidity('用户名不能为空');
            valid.uname = false;
        }else if(this.validity.tooShort){
            setMsg(this,'用户名不能少于3位','error');
            this.setCustomValidity('用户名不能少于3位');
            valid.uname = false;
        }else{
            setMsg(this,'用户名格式正确','success');
            this.setCustomValidity('');
            valid.uname = true;
        }
    };
    uname.oninput = function(){ this.setCustomValidity(''); };

    /* 2. 对密码进行验证 */
    upwd.onfocus = function(){
        setMsg(this,'密码长度在6到12位之间','default');
    };
    upwd.onblur = function(){
        if(upwd.value === '' || upwd.value.length < 6){
            setMsg(this,'密码至少为6位数字或字符','error');
            valid.upwd = false;
        }else{
            setMsg(this,'输入正确','success');
            valid.upwd = true;
        }
        // 密码改变时，如果确认密码已填，触发确认密码重新校验
        if(upwd2.value) upwd2.onblur.call(upwd2);
    };

    /* 3. 对确认密码进行验证 */
    upwd2.onblur = function(){
        if(upwd2.value === ''){
            setMsg(this,'请再次输入密码','error');
            valid.upwd2 = false;
        }
        else if(upwd2.value !== upwd.value){
            setMsg(this,'两次密码输入不一致','error');
            valid.upwd2 = false;
        }
        else{
            setMsg(this,'输入正确','success');
            valid.upwd2 = true;
        }
    };

    /* 4. 对手机号进行验证 */
    var phoneReg = /^1[3-9]\d{9}$/;
    uphone.onfocus = function(){
        setMsg(this,'请输入合法的手机号码','default');
    };
    uphone.onblur = function(){
        if(this.validity.valueMissing){
            setMsg(this,'电话号码不能为空','error');
            valid.uphone = false;
        }else if(!phoneReg.test(uphone.value)){
            setMsg(this,'电话号码格式不正确','error');
            valid.uphone = false;
        }else{
            setMsg(this,'格式正确','success');
            valid.uphone = true;
        }
    };

    /* 5. 提交注册 */
    $('#btn_reg').click(function(){
        // 提交前强制触发一次所有字段的校验
        uname.onblur.call(uname);
        upwd.onblur.call(upwd);
        upwd2.onblur.call(upwd2);
        uphone.onblur.call(uphone);

        if(!allValid()){ return; }

        // 防止重复提交
        var $btn = $(this);
        $btn.prop('disabled', true).val('提交中...');

        // 表单序列化，获得所有的用户输入
        var data = $('#user_info').serialize();

        // 异步提交请求数据
        $.ajax({
            type: 'POST',
            dataType: 'json',
            url: 'reg',
            data: data,
            success: function(result){
                if(result.type == 'success'){
                    alert('注册成功！');
                    location.href = 'login';
                }else {
                    alert(result.msg);
                    $btn.prop('disabled', false).val('提交注册信息');
                }
            },
            error: function(){
                alert('网络异常，请稍后重试');
                $btn.prop('disabled', false).val('提交注册信息');
            }
        });
    });

    /* 6. 轮播图功能 */
    $(function(){
        var imgs = [
            '../resources/home/images/new1.png',
            '../resources/home/images/new2.png',
            '../resources/home/images/new3.png'
        ];
        var idx = 0;
        var $img = $("#trigger img");
        setInterval(function(){
            idx = (idx + 1) % imgs.length;
            $img.attr("src", imgs[idx]);
        }, 2000);
    });
</script>

</body>
</html>