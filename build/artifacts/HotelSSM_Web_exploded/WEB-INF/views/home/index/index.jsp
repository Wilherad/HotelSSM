

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<!doctype html>
<html lang="zh">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <!-- 移动端适配：视口设置，需放在 head 顶部 -->
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <meta name="Author" content="万林酒店">
    <meta name="Keywords" content="酒店管理系统">
    <meta name="Description" content="酒店管理系统">
    <link href="../resources/home/css/reservation.css" type="text/css" rel="Stylesheet"/>
    <link href="../resources/home/css/index.css" type="text/css" rel="Stylesheet"/>
    <title>万林酒店|酒店管理系统首页</title>

    <!-- ===== 移动端适配样式（内联，覆盖外部 CSS；PC 端外观基本不变） ===== -->
    <style>
        html, body { max-width: 100%; overflow-x: hidden; }
        img { max-width: 100%; }
        #subject { width: 100%; }
        #subject > img { width: 100%; height: auto; display: block; }
        #subject > p { float: none; text-align: right; padding: 6px 10px; }
        #due_menu, #guest_rooms { width: 100%; box-sizing: border-box; }
        .chioce { display: flex; flex-wrap: wrap; gap: 8px; box-sizing: border-box; padding: 0 10px; }
        .chioce input[type="text"] { flex: 1 1 60%; min-width: 0; box-sizing: border-box; }
        .chioce input[type="button"] { flex: 0 0 auto; }
        #guest_rooms { overflow-x: auto; -webkit-overflow-scrolling: touch; }

        .room-cards { display: none; padding: 10px; box-sizing: border-box; }
        .room-card {
            border: 1px solid #e2e2e2; border-radius: 8px;
            margin-bottom: 12px; overflow: hidden; background: #fff;
            box-shadow: 0 1px 3px rgba(0,0,0,.06);
        }
        .room-card .rc-photo img { width: 100%; height: 160px; object-fit: cover; display: block; }
        .room-card .rc-body { padding: 10px 12px; }
        .room-card .rc-title { font-size: 16px; font-weight: bold; margin: 0 0 4px; }
        .room-card .rc-remark { color: #888; font-size: 13px; margin: 0 0 10px; line-height: 1.5; }
        .room-card .rc-meta { display: flex; flex-wrap: wrap; gap: 6px 16px; font-size: 13px; color: #555; margin-bottom: 10px; }
        .room-card .rc-meta b { color: #d9534f; font-size: 16px; }
        .room-card .rc-foot { display: flex; align-items: center; justify-content: space-between; }
        .room-card .rc-status { font-size: 13px; }
        .room-card .rc-status .full { color: #999; }
        .room-card .rc-status .ok { color: #2a9f4b; }
        .room-card .rc-btn {
            border: none; border-radius: 20px; padding: 8px 22px;
            background: #d9534f; color: #fff; font-size: 14px; cursor: pointer;
        }
        .room-card .rc-btn.disable { background: #ccc; color: #fff; cursor: not-allowed; }

        /* ============ AI 智能房间推荐助手样式（主题色沿用本站 #d9534f） ============ */
        #ai-chat-btn {
            position: fixed; bottom: 30px; right: 30px;
            width: 60px; height: 60px; border-radius: 50%;
            background: #d9534f; color: #fff; border: none; font-size: 24px;
            cursor: pointer; box-shadow: 0 4px 12px rgba(0,0,0,.18);
            display: flex; align-items: center; justify-content: center;
            transition: transform .2s; z-index: 99999;
        }
        #ai-chat-btn:hover { transform: scale(1.06); }
        #ai-chat-win {
            position: fixed; bottom: 100px; right: 30px;
            width: 360px; max-width: 92vw; height: 520px; max-height: 80vh;
            background: #fff; border-radius: 12px;
            box-shadow: 0 5px 25px rgba(0,0,0,.22);
            display: none; flex-direction: column; overflow: hidden; z-index: 99999;
        }
        #ai-chat-win.active { display: flex; }
        .ai-chat-head {
            background: #d9534f; color: #fff; padding: 14px 15px; font-weight: bold;
            display: flex; justify-content: space-between; align-items: center;
        }
        .ai-chat-head .ai-close { background: none; border: none; color: #fff; font-size: 20px; cursor: pointer; line-height: 1; }
        #ai-chat-msgs {
            flex: 1; padding: 14px; overflow-y: auto; background: #f6f7f9;
            display: flex; flex-direction: column; gap: 10px;
        }
        .ai-msg { max-width: 82%; padding: 10px 14px; border-radius: 16px; line-height: 1.55; font-size: 14px; white-space: pre-wrap; word-break: break-word; }
        .ai-msg.bot { background: #ececec; color: #333; align-self: flex-start; border-bottom-left-radius: 4px; }
        .ai-msg.user { background: #d9534f; color: #fff; align-self: flex-end; border-bottom-right-radius: 4px; }
        .ai-msg a { color: inherit; text-decoration: underline; }
        .ai-quick { display: flex; flex-wrap: wrap; gap: 6px; padding: 8px 12px 0; }
        .ai-quick button { border: 1px solid #d9534f; color: #d9534f; background: #fff; border-radius: 14px; padding: 4px 10px; font-size: 12px; cursor: pointer; }
        .ai-chat-in { padding: 10px; background: #fff; border-top: 1px solid #e2e2e2; display: flex; gap: 8px; }
        #ai-input { flex: 1; padding: 10px; border: 1px solid #ccc; border-radius: 20px; outline: none; font-size: 14px; }
        #ai-send { padding: 0 18px; background: #d9534f; color: #fff; border: none; border-radius: 20px; cursor: pointer; font-size: 14px; }
        #ai-send:disabled { background: #ccc; cursor: not-allowed; }

        @media screen and (max-width: 768px) {
            .shade_mag { display: none !important; }
            #subject > p { text-align: center; }
            #pro_list { display: none !important; }
            .room-cards { display: block !important; }
            #ai-chat-win { right: 10px; bottom: 90px; width: 92vw; height: 75vh; }
        }
    </style>
</head>
<body>
<!--头部-->
<div id="c_header"></div>
<!--主体内容-->
<section>
    <div id="subject">
        <p>
            <c:if test="${account == null }">
                <a href="../home/login">登录</a>&nbsp;&nbsp;|&nbsp;&nbsp;
                <a href="../home/reg">注册</a>&nbsp;
            </c:if>
            <c:if test="${account != null }">
                <font color="red">欢迎您：${account.name }&nbsp;&nbsp;|&nbsp;&nbsp;</font>
                <a href="account/index">用户中心</a>&nbsp;&nbsp;|&nbsp;&nbsp;
                <a href="../home/logout">注销登录</a>&nbsp;
            </c:if>
        </p>
        <img src="../resources/home/images/indexIMG.png" alt="">
        <!--遮罩-->
        <ul class="shade_mag">
            <li><img src="../resources/home/images/s_02.png" alt=""></li>
            <li><img src="../resources/home/images/s_01.png" alt=""></li>
        </ul>

    </div>

    <!---->
    <!---预订菜单--->
    <div id="due_menu">
        <!--客房-->
        <div id="guest_rooms">
            <p class="booking_tab"><span></span>客房列表</p>
            <div class="chioce">
                <input type="text" placeholder="关键字" value="${kw }" id="kw"/>
                <input type="button" value="搜索" id="search-btn"/>
            </div>
            <form style="display:none;" action="index" method="get" id="search-form"><input type="hidden" name="name" id="search-name"></form>
            <!--列表（PC 表格）-->
            <table id="pro_list">
                <thead>
                <tr>
                    <th width="200px">客房</th>
                    <th>房型</th>
                    <th>可住人数</th>
                    <th>床位数</th>
                    <th>房价</th>
                    <th>房态</th>
                    <th>预订</th>
                </tr>
                </thead>
                <tbody >
                <c:forEach items="${roomTypeList }" var="roomType">
                    <tr>
                        <td><a href="#"><img src="${roomType.photo }" alt=""></a>
                        </td>
                        <td align="center">
                            <p>${roomType.name }</p>
                            <p class="sub_txt">${roomType.remark }</p>
                        </td>
                        <td>${roomType.liveNum }</td>
                        <td>${roomType.bedNum }</td>
                        <td>${roomType.price }</td>
                        <td>
                            <c:if test="${roomType.status == 0 }">
                                已满房
                            </c:if>
                            <c:if test="${roomType.status == 1 }">
                                可预订
                            </c:if>
                        </td>
                        <td>
                            <c:if test="${roomType.status == 0 }">
                                <input type="button" class="disable" value="满房" >
                            </c:if>
                            <c:if test="${roomType.status == 1 }">
                                <input type="button" value="预订" onclick="window.location.href='account/book_order?roomTypeId=${roomType.id }'" >
                            </c:if>
                        </td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>

            <!--列表（移动端卡片）-->
            <div class="room-cards">
                <c:forEach items="${roomTypeList }" var="roomType">
                    <div class="room-card">
                        <div class="rc-photo"><img src="${roomType.photo }" alt=""></div>
                        <div class="rc-body">
                            <p class="rc-title">${roomType.name }</p>
                            <p class="rc-remark">${roomType.remark }</p>
                            <div class="rc-meta">
                                <span>房价 <b>￥${roomType.price }</b></span>
                                <span>可住 ${roomType.liveNum } 人</span>
                                <span>床位 ${roomType.bedNum }</span>
                            </div>
                            <div class="rc-foot">
                <span class="rc-status">
                  <c:if test="${roomType.status == 0 }"><span class="full">已满房</span></c:if>
                  <c:if test="${roomType.status == 1 }"><span class="ok">可预订</span></c:if>
                </span>
                                <c:if test="${roomType.status == 0 }">
                                    <input type="button" class="rc-btn disable" value="满房">
                                </c:if>
                                <c:if test="${roomType.status == 1 }">
                                    <input type="button" class="rc-btn" value="预订"
                                           onclick="window.location.href='account/book_order?roomTypeId=${roomType.id }'">
                                </c:if>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>

            <div id="pages"></div>
            <div></div>
        </div>
    </div>

</section>
<%@include file="../common/footer.jsp"%>

<!-- ============ AI 智能房间推荐助手 ============ -->
<!-- 真实房型数据：用隐藏 data-* 属性由后端渲染，浏览器读取 dataset 时自动解码 HTML 实体，无转义烦恼 -->
<div id="room-data" style="display:none;">
    <c:forEach items="${roomTypeList }" var="rt">
        <span class="rd"
              data-id="${rt.id }"
              data-name="${fn:escapeXml(rt.name ) }"
              data-remark="${fn:escapeXml(rt.remark ) }"
              data-price="${rt.price }"
              data-live="${rt.liveNum }"
              data-bed="${rt.bedNum }"
              data-status="${rt.status }"></span>
    </c:forEach>
</div>

<button id="ai-chat-btn" onclick="aiToggle()" title="AI 智能推荐">&#128172;</button>
<div id="ai-chat-win">
    <div class="ai-chat-head">
        <span>AI 智能房间推荐</span>
        <button class="ai-close" onclick="aiToggle()">&times;</button>
    </div>
    <div id="ai-chat-msgs">
        <div class="ai-msg bot">您好！我是万林酒店的智能管家。告诉我您的入住人数、预算或偏好（如安静、带阳台、亲子等），我来为您推荐合适的房间。</div>
    </div>
    <div class="ai-quick">
        <button onclick="aiQuick('推荐几个可预订的房间')">推荐可预订房</button>
        <button onclick="aiQuick('适合亲子的房间')">适合亲子</button>
        <button onclick="aiQuick('预算500以内的房间')">预算500以内</button>
        <button onclick="aiQuick('安静高层的房间')">安静高层</button>
    </div>
    <div class="ai-chat-in">
        <input type="text" id="ai-input" placeholder="输入您的需求..." onkeydown="if(event.key==='Enter')aiSend()">
        <button id="ai-send" onclick="aiSend()">发送</button>
    </div>
</div>

<script src="../resources/home/js/jquery-1.11.3.js"></script>
<script>
    $(document).ready(function(){
        $("#search-btn").click(function(){
            $("#search-name").val($("#kw").val());
            $("#search-form").submit();
        })
    });
</script>

<!-- ============ AI 推荐助手逻辑 ============ -->
<script>
    // 后端代理接口地址：带 JSP 上下文路径，避免部署路径变化导致 404；API Key 永远只在后端
    var AI_CHAT_API = '<%= request.getContextPath() %>/api/chat';

    // 从隐藏 data-* 读取真实房型（与列表同一份后端数据，价格/房态实时一致，杜绝模型编造）
    var ROOMS = (function () {
        var arr = [];
        var nodes = document.querySelectorAll('#room-data .rd');
        for (var i = 0; i < nodes.length; i++) {
            var d = nodes[i].dataset;
            arr.push({
                id: d.id,
                name: d.name || '',
                remark: d.remark || '',
                price: d.price,
                liveNum: d.live,
                bedNum: d.bed,
                status: d.status
            });
        }
        return arr;
    })();

    // 把房型拼进系统提示词；强调价格/房态以数据为准，并约定预订标记格式
    var SYSTEM_PROMPT =
        '你是“万林酒店”的智能房间推荐助手。下面是本店当前全部房型（JSON）：\n' +
        JSON.stringify(ROOMS) +
        '\n字段说明：name=房型名称, remark=房型描述, price=房价(元), liveNum=可住人数, bedNum=床位数, status(1=可预订,0=已满房)。' +
        '规则：' +
        '1. 只能从上述房型中推荐，绝不能编造不存在的房型或价格，价格与房态必须与该数据一致。' +
        '2. 优先推荐 status 为 1（可预订）的房间；若用户想要的房型已满房，要说明并推荐相近的可预订房型。' +
        '3. 用户若未说明人数/预算/偏好，主动礼貌追问。' +
        '4. 推荐时给出：房型名称、房价、可住人数、推荐理由（结合 remark）。语气热情简洁，控制在120字以内。' +
        '5. 每推荐一个可预订房型，单独一行附上形如 [预订:房型id数字] 的标记，前端会渲染成预订按钮。';

    var  chatHistory = [{ role: 'system', content: SYSTEM_PROMPT }];

    function aiToggle() {
        var w = document.getElementById('ai-chat-win');
        w.classList.toggle('active');
        if (w.classList.contains('active')) document.getElementById('ai-input').focus();
    }
    function aiQuick(t) {
        document.getElementById('ai-input').value = t;
        aiSend();
    }
    function aiAppend(role, text, asHtml) {
        var box = document.getElementById('ai-chat-msgs');
        var d = document.createElement('div');
        d.className = 'ai-msg ' + role;
        if (asHtml) { d.innerHTML = text; } else { d.textContent = text; }
        box.appendChild(d);
        box.scrollTop = box.scrollHeight;
        return d;
    }
    // 先转义防 XSS，再把 [预订:id] 替换成可跳转的预订按钮（复用本站预订链接格式）
    function aiRenderReply(text) {
        var safe = text.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
        safe = safe.replace(/\[预订:(\d+)\]/g, function (m, id) {
            return ' <a href="account/book_order?roomTypeId=' + id + '" style="display:inline-block;background:#d9534f;color:#fff;border-radius:12px;padding:2px 12px;text-decoration:none;margin:2px 0;">立即预订</a> ';
        });
        return safe;
    }

    function aiSend() {
        var input = document.getElementById('ai-input');
        var sendBtn = document.getElementById('ai-send');
        var userText = input.value.trim();
        if (!userText) return;

        aiAppend('user', userText);
        input.value = '';
        sendBtn.disabled = true;
        chatHistory.push({ role: 'user', content: userText });

        var botMsg = aiAppend('bot', '正在为您匹配房间...');

        fetch(AI_CHAT_API, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ messages: chatHistory })
        })
            .then(function (resp) {
                if (!resp.ok) throw new Error('网络请求失败 ' + resp.status);
                return resp.json();
            })
            .then(function (data) {
                var reply = data.reply || '抱歉，暂时没有匹配到合适的房间，您可以换个说法再试试。';
                botMsg.innerHTML = aiRenderReply(reply);
                chatHistory.push({ role: 'assistant', content: reply });
            })
            .catch(function (e) {
                console.error(e);
                botMsg.textContent = '抱歉，系统繁忙，请稍后再试。';
                chatHistory.pop();
            })
            .finally(function () {
                sendBtn.disabled = false;
                input.focus();
                var box = document.getElementById('ai-chat-msgs');
                box.scrollTop = box.scrollHeight;
            });
    }
</script>
</body>
</html>