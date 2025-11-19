import Component from "@glimmer/component";
import TopicInGatedCategory from "../../components/topic-in-gated-category";

export default class GatedUserProfile extends Component {
  get profileUser() {
    return this.args.model;
  }

  <template>
    <TopicInGatedCategory
      @pageGate={{true}}
      @profileUser={{this.profileUser}}
      @pageType={{"profile"}}
    />
  </template>
}
