
/*使用说明：
<input type="file" onchanage="PerView(obj,'perViewID')"/>
<div id="perViewID">显示预览图片DIV</div>
*/
function PerView(obj, perViewID) {//参数:obj当前input file 标签对象，参数:perViewName预览DIV的ID

    // 验证图片格式
    if (!obj.value.match(/.jpg|.gif|.png|.bmp/g)) {
        alert('图片格式无效！');
        return false;
    }

    //获取预览图片DIV
    var perViewDiv = document.getElementById(perViewID);

    //判断并设置预览DIV高宽
    if (perViewDiv.style.width == "") {
        perViewDiv.style.width = "200px";
    }
    if (perViewDiv.style.height == "") {
        perViewDiv.style.height = "200px";
    }

    //获取浏览器版本号
    var Agent = window.navigator.userAgent.toString();

    if (Agent.indexOf("MSIE") != -1) {

        //变量储存当前选择文件路由(url)
        var imgUrl = "file://localhost/";

        //判断是否为IE8并分别获取文件路由(url)
        if (Agent.indexOf("MSIE 8") != -1) {
            obj.select();
            imgUrl += document.selection.createRange().text;
        } else {
            imgUrl += obj.value;
        }


        //呈现图片(滤镜方法呈现因为IE在较高版本上<img/>不支持显示本地图片)
        perViewDiv.style.filter = "progid:DXImageTransform.Microsoft.AlphaImageLoader(sizingMethod='scale',src='" + imgUrl + "');";
    }

    if (Agent.indexOf("Firefox") != -1) {
        var imgUrl = "";
        if (Agent.indexOf("Firefox") != -1) {
            //火狐路径获取又改!
            imgUrl = window.URL.createObjectURL(obj.files[0]);
        }
        else {
            //变量储存当前选择文件路由(url)注意:由于FF考虑到安全问题不能直接根据inoput file 的value获取路由，且当下方
            //法获取的路由为FF加密文档只适用于FF浏览器(FF = 火狐)
            imgUrl = obj.files[0].getAsDataURL();
        }
        //呈现图片
        perViewDiv.innerHTML = "<img width='100%' height='100%' src='" + imgUrl + "' />";
    }
}
