import { Component } from '@angular/core';

@Component({
  selector: 'loading',
  template: `
    <div class="floating-circles-g">
      <div class="f_circle_g frotate_g_01"></div>
      <div class="f_circle_g frotate_g_02"></div>
      <div class="f_circle_g frotate_g_03"></div>
      <div class="f_circle_g frotate_g_04"></div>
      <div class="f_circle_g frotate_g_05"></div>
      <div class="f_circle_g frotate_g_06"></div>
      <div class="f_circle_g frotate_g_07"></div>
      <div class="f_circle_g frotate_g_08"></div>
    </div>
  `,
  styles: [`
    .floating-circles-g{
    	position:relative;
    	width:45px;
    	height:45px;
    	margin:auto;
    	transform:scale(0.6);
    		-o-transform:scale(0.6);
    		-ms-transform:scale(0.6);
    		-webkit-transform:scale(0.6);
    		-moz-transform:scale(0.6);
    }

    .f_circle_g{
    	position:absolute;
    	background-color:rgb(255,255,255);
    	height:8px;
    	width:8px;
    	border-radius:4px;
    		-o-border-radius:4px;
    		-ms-border-radius:4px;
    		-webkit-border-radius:4px;
    		-moz-border-radius:4px;
    	animation-name:f_fade_g;
    		-o-animation-name:f_fade_g;
    		-ms-animation-name:f_fade_g;
    		-webkit-animation-name:f_fade_g;
    		-moz-animation-name:f_fade_g;
    	animation-duration:1.2s;
    		-o-animation-duration:1.2s;
    		-ms-animation-duration:1.2s;
    		-webkit-animation-duration:1.2s;
    		-moz-animation-duration:1.2s;
    	animation-iteration-count:infinite;
    		-o-animation-iteration-count:infinite;
    		-ms-animation-iteration-count:infinite;
    		-webkit-animation-iteration-count:infinite;
    		-moz-animation-iteration-count:infinite;
    	animation-direction:normal;
    		-o-animation-direction:normal;
    		-ms-animation-direction:normal;
    		-webkit-animation-direction:normal;
    		-moz-animation-direction:normal;
    }

    .frotate_g_01{
    	left:0;
    	top:18px;
    	animation-delay:0.45s;
    		-o-animation-delay:0.45s;
    		-ms-animation-delay:0.45s;
    		-webkit-animation-delay:0.45s;
    		-moz-animation-delay:0.45s;
    }

    .frotate_g_02{
    	left:5px;
    	top:5px;
    	animation-delay:0.6s;
    		-o-animation-delay:0.6s;
    		-ms-animation-delay:0.6s;
    		-webkit-animation-delay:0.6s;
    		-moz-animation-delay:0.6s;
    }

    .frotate_g_03{
    	left:18px;
    	top:0;
    	animation-delay:0.75s;
    		-o-animation-delay:0.75s;
    		-ms-animation-delay:0.75s;
    		-webkit-animation-delay:0.75s;
    		-moz-animation-delay:0.75s;
    }

    .frotate_g_04{
    	right:5px;
    	top:5px;
    	animation-delay:0.9s;
    		-o-animation-delay:0.9s;
    		-ms-animation-delay:0.9s;
    		-webkit-animation-delay:0.9s;
    		-moz-animation-delay:0.9s;
    }

    .frotate_g_05{
    	right:0;
    	top:18px;
    	animation-delay:1.05s;
    		-o-animation-delay:1.05s;
    		-ms-animation-delay:1.05s;
    		-webkit-animation-delay:1.05s;
    		-moz-animation-delay:1.05s;
    }

    .frotate_g_06{
    	right:5px;
    	bottom:5px;
    	animation-delay:1.2s;
    		-o-animation-delay:1.2s;
    		-ms-animation-delay:1.2s;
    		-webkit-animation-delay:1.2s;
    		-moz-animation-delay:1.2s;
    }

    .frotate_g_07{
    	left:18px;
    	bottom:0;
    	animation-delay:1.35s;
    		-o-animation-delay:1.35s;
    		-ms-animation-delay:1.35s;
    		-webkit-animation-delay:1.35s;
    		-moz-animation-delay:1.35s;
    }

    .frotate_g_08{
    	left:5px;
    	bottom:5px;
    	animation-delay:1.5s;
    		-o-animation-delay:1.5s;
    		-ms-animation-delay:1.5s;
    		-webkit-animation-delay:1.5s;
    		-moz-animation-delay:1.5s;
    }



    @keyframes f_fade_g{
    	0%{
    		background-color:rgb(0,0,0);
    	}

    	100%{
    		background-color:rgb(255,255,255);
    	}
    }

    @-o-keyframes f_fade_g{
    	0%{
    		background-color:rgb(0,0,0);
    	}

    	100%{
    		background-color:rgb(255,255,255);
    	}
    }

    @-ms-keyframes f_fade_g{
    	0%{
    		background-color:rgb(0,0,0);
    	}

    	100%{
    		background-color:rgb(255,255,255);
    	}
    }

    @-webkit-keyframes f_fade_g{
    	0%{
    		background-color:rgb(0,0,0);
    	}

    	100%{
    		background-color:rgb(255,255,255);
    	}
    }

    @-moz-keyframes f_fade_g{
    	0%{
    		background-color:rgb(0,0,0);
    	}

    	100%{
    		background-color:rgb(255,255,255);
    	}
    }
  `],
  providers: []
})
export class LoadingComponent {
  constructor() { }
}
