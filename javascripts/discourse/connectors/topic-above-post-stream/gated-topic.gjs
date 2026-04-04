import Component from "@glimmer/component";
import { classNames } from "@ember-decorators/component";
import TopicInGatedCategory from "../../components/topic-in-gated-category";

@classNames("topic-above-post-stream-outlet", "topic-in-gated-category")
export default class GatedTopic extends Component {
  <template>
    <TopicInGatedCategory
      @categoryId={{this.args.model.category_id}}
      @tags={{this.args.model.tags}}
      @pageType={{"topic"}}
    />
  </template>
}
