
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!doctype html>
<html lang="zh">
<head>
    <meta charset="UTF-8">
    <title>酒店预订|酒店管理系统预定房间</title>
    <meta name="Author" content="酒店预订">
    <meta name="Keywords" content="酒店预订酒店管理系统">
    <meta name="Description" content="酒店预订酒店管理系统">
    <link rel="stylesheet" href="../../resources/home/css/index.css">
    <link rel="stylesheet" href="../../resources/home/css/order.css">
    <link rel="stylesheet" href="../../resources/home/css/jquery-ui.min.css">
</head>
<body>
<!--- 页头--->
<div id="c_header"></div>
<!----主体-->
<div id="section">
    <!--客房信息-->
    <div class="hotel_inf_w">

        <div class="hotel_roominfobox">
            <a href="#"><img src="${roomType.photo }" alt=""/></a>
            <div class="info">
                <h2>${roomType.name }</h2>
                <!--豪华双人房&#45;&#45;&#45;&#45;预定-->
            </div>
            <ul class="hotel_detail">
                <li><span>预定数:</span>${roomType.bookNum }</li>
                <li><span>房价:</span>${roomType.price }</li>
                <li><span>床位数:</span>${roomType.bedNum }</li>
                <li><span>可住:</span>${roomType.liveNum }人</li>
                <li><span>其他:</span>${roomType.remark }</li>
            </ul>
        </div>
        <div class="jump">

            <a href="../index">更多房型</a>
        </div>
    </div>
    <!--预定信息-->
    <div class="book_info">
        <form id="order_info">
            <ul>
                <input type="hidden" name="rid" value=""/>
                <li>
                    <h3>预定信息</h3>

                    <div class="info_group">
                        <label>入住时间</label><input type="text" name="arriveDate" id="arriveDate" class="datepicker"/>
                        <label>离店时间</label><input type="text" name="leaveDate" id="leaveDate" class="datepicker"/>
                    </div>

                    <div class="info_group">
                        <label>房费总计</label><span class="total">￥${roomType.price }</span>
                        <!-- 计算出的房费总额：晚数 * 单价，提交时随表单一起发送 -->
                        <input type="hidden" name="totalPrice" id="totalPrice" value="${roomType.price }"/>
                    </div>
                </li>
                <li>
                    <h3>入住信息</h3>

                    <div class="info_group">
                        <label>姓&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;名</label><input type="text" name="name" id="name" value="${account.name}"/><span class="msg"></span>
                    </div>
                    <div class="info_group">
                        <label>电&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;话</label><input type="text" maxlength="11" name="mobile" id="mobile" value="${account.mobile}"/><span class="msg"></span>
                    </div>
                    <div class="info_group">
                        <label>身份证号</label><input type="text" name="idCard" id="idCard" value="${account.idCard}"/><span class="msg"></span>
                    </div>
                    <div class="info_group">
                        <label for="massage">留&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;言</label>
                        <textarea id="remark" name="remark" style="width:200px;"></textarea>
                    </div>

                </li>
                <li>
                    <div class="msg">
                        预定须知:请携带好本人的身份证，办理入住手续，本店办理入住需要在前台缴费押金 ￥500

                    </div>
                    <div id="btn_booking">确认预定</div>

                </li>
            </ul>
        </form>
    </div>

    <div class="malog">
        <div class="message">
            <p class="msgs"></p>
            <p>您可以在 <a href="index#order">我的订单</a>查看详情</p>
            <p>系统会在<span class="num">5</span>秒后跳转会 <a href="../index">菜单列表</a></p>
        </div>
    </div>

</div>
<!----页底--->
<div id="c_footer"></div>
<script src="../../resources/home/js/jquery-1.11.3.js"></script>
<script src="../../resources/home/js/jquery-ui.min.js"></script>
</body>
<script>
    // 单晚房价（由后台 roomType.price 注入，供前端按晚数计算房费）
    var roomPrice = parseFloat('${roomType.price }') || 0;

    /*
     * 房费计算：房费总计 = 入住晚数 * 单晚房价
     * 入住晚数 = 离店日期 - 入住日期（按自然日相差的天数，即住几晚）
     * 例：入住 2024-01-01、离店 2024-01-04 -> 晚数=3 -> 3 晚 * 399 = 1197
     */
    function calcTotal(){
        var arriveDate = $("#arriveDate").val();
        var leaveDate  = $("#leaveDate").val();
        if(!arriveDate || !leaveDate){
            // 未选完日期时，恢复显示单晚房价
            $(".total").text("￥" + roomPrice);
            $("#totalPrice").val(roomPrice);
            return;
        }
        // 把 "yy-mm-dd" 转成 Date（用 / 分隔兼容 IE）
        var t1 = Date.parse(arriveDate.replace(/-/g, "/"));
        var t2 = Date.parse(leaveDate.replace(/-/g, "/"));
        if(isNaN(t1) || isNaN(t2)){ return; }
        // 相差的毫秒数换算成天数 = 入住晚数
        var nights = Math.round((t2 - t1) / (1000 * 60 * 60 * 24));
        if(nights <= 0){
            $(".total").text("￥" + roomPrice + "（离店时间需晚于入住时间）");
            $("#totalPrice").val(roomPrice);
            return;
        }
        var total = nights * roomPrice;          // 核心公式：晚数 * 单价
        $(".total").text("￥" + total + "（" + nights + "晚 * " + roomPrice + "）");
        $("#totalPrice").val(total);
    }

    $(function() {
        $(".datepicker").datepicker({
            "dateFormat":"yy-mm-dd",
            // 选完日期后立即重算房费
            onClose: function(){ calcTotal(); },
            onSelect: function(){ calcTotal(); }
        });

        // 兼容手动输入日期的情况
        $("#arriveDate, #leaveDate").on("change blur keyup", calcTotal);

        // 初始化一次（无日期时显示单晚房价）
        calcTotal();

        $("#btn_booking").click(function(){
            var arriveDate = $("#arriveDate").val();
            var leaveDate = $("#leaveDate").val();
            if(arriveDate == '' || leaveDate == ''){
                alert('请选择时间!');
                return;
            }
            // 选完日期后校验晚数是否合法
            var t1 = Date.parse(arriveDate.replace(/-/g, "/"));
            var t2 = Date.parse(leaveDate.replace(/-/g, "/"));
            if(isNaN(t1) || isNaN(t2) || t2 <= t1){
                alert('离店时间必须晚于入住时间!');
                return;
            }
            calcTotal(); // 提交前确保房费总额是最新的
            var name = $("#name").val();
            if(name == ''){
                $("#name").next("span.msg").text('请填写入住人!');
                return;
            }
            $("#name").next("span.msg").text('');
            var mobile = $("#mobile").val();
            if(mobile == ''){
                $("#mobile").next("span.msg").text('请填写手机号!');
                return;
            }
            $("#mobile").next("span.msg").text('');
            var idCard = $("#idCard").val();
            if(idCard == ''){
                $("#idCard").next("span.msg").text('请填写身份证号!');
                return;
            }
            $("#idCard").next("span.msg").text('');
            var remark = $("#remark").val();
            $.ajax({
                url:'book_order',
                type:'post',
                dataType:'json',
                data:{roomTypeId:'${roomType.id }',name:name,mobile:mobile,idCard:idCard,remark:remark,arriveDate:arriveDate,leaveDate:leaveDate,totalPrice:$("#totalPrice").val()},
                success:function(data){
                    if(data.type == 'success'){
                        $(".malog").show();
                        setTimeout(function(){
                            window.location.href = 'index';
                        },1000)
                    }else{
                        alert(data.msg);
                    }
                }
            });
        })
    });
</script>
</html>