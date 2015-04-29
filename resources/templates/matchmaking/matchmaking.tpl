<div class="matchmakingInner">
    <div class="leftColumn">

        <div class="nationSelect">
            {{#nations}}
                <div id="nation_{{id}}" class="nation {{color}}">{{name}}</div>
            {{/nations}}
        </div>
        <br>

        <div class="hostGame">
            <label for="gold">{{lang.gold}}</label><input id="gold" class="inputGold" type="text" value="50"><br>
            <button class="performHostGame">{{lang.hostGame}}</button>
        </div>
        <div class="clearer"></div>
        <div class="players"></div>
        <div class="clearer"></div>

    </div>
    <div class="games"></div>
</div>