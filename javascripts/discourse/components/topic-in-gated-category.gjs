import Component from "@ember/component";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { tagName } from "@ember-decorators/component";
import DButton from "discourse/components/d-button";
import routeAction from "discourse/helpers/route-action";
import discourseComputed from "discourse/lib/decorators";
import { i18n } from "discourse-i18n";

@tagName("")
export default class TopicInGatedCategory extends Component {
  @service router;

  hidden = true;
  enabledCategories = settings.enabled_categories
    .split("|")
    .map((id) => parseInt(id, 10))
    .filter((id) => id);
  enabledTags = settings.enabled_tags.split("|").filter(Boolean);

  didInsertElement() {
    super.didInsertElement(...arguments);
    this.recalculate();
  }

  didUpdateAttrs() {
    super.didUpdateAttrs(...arguments);
    this.recalculate();
  }

  willDestroyElement() {
    super.willDestroyElement(...arguments);
    document.body.classList.remove("topic-in-gated-category");
  }

  isUserInInsidersGroup() {
    if (!this.currentUser || !this.currentUser.groups) {
      return false;
    }

    return this.currentUser.groups.some((g) => g.name === "insider");
  }

  recalculate() {
    const pageType = this.pageType;

    const isAnonymous = !this.currentUser;
    const isAdmin = this.currentUser?.admin;
    const isInsider = this.isUserInInsidersGroup();

    const isOwnProfile =
      pageType === "profile" &&
      this.profileUser &&
      this.profileUser.id === this.currentUser?.id;

    if (isAdmin) {
      document.body.classList.remove("topic-in-gated-category");
      this.set("hidden", true);
      return;
    }

    if (isInsider) {
      document.body.classList.remove("topic-in-gated-category");
      this.set("hidden", true);
      return;
    }

    if (pageType === "directory") {
      document.body.classList.add("topic-in-gated-category");
      this.set("hidden", false);
      return;
    }

    if (pageType === "profile") {
      if (isOwnProfile) {
        document.body.classList.remove("topic-in-gated-category");
        this.set("hidden", true);
        return;
      }

      document.body.classList.add("topic-in-gated-category");
      this.set("hidden", false);
      return;
    }

    if (pageType === "topic") {
      const gatedByTag = this.tags?.some((t) => this.enabledTags.includes(t));

      const gatedByCategory = this.enabledCategories.includes(this.categoryId);

      const topicIsGated = gatedByTag || gatedByCategory;

      if (!topicIsGated) {
        document.body.classList.remove("topic-in-gated-category");
        this.set("hidden", true);
        return;
      }

      document.body.classList.add("topic-in-gated-category");
      this.set("hidden", false);
      return;
    }

    document.body.classList.remove("topic-in-gated-category");
    this.set("hidden", true);
  }

  @discourseComputed("hidden")
  shouldShow(hidden) {
    return !hidden;
  }

  @action
  redirectToSignup() {
    window.open(
      i18n(themePrefix("sign_up_redirect_url")),
      "_blank",
      "noopener"
    );
  }

  <template>
    {{#if this.shouldShow}}
      <div class="custom-gated-topic-container">
        <div class="custom-gated-topic-content">
          <div class="custom-gated-topic-content--header">
            {{i18n (themePrefix "heading_text")}}
          </div>

          <p class="custom-gated-topic-content--text">
            {{i18n (themePrefix "subheading_text")}}
          </p>

          <div class="custom-gated-topic-content--cta">
            <div class="custom-gated-topic-content--cta__signup">
              <DButton
                @action={{this.redirectToSignup}}
                class="btn-primary btn-large sign-up-button"
                @translatedLabel={{i18n (themePrefix "signup_cta_label")}}
              />
            </div>

            <div class="custom-gated-topic-content--cta__login">
              <DButton
                @action={{routeAction "showLogin"}}
                @id="cta-login-link"
                class="btn btn-text login-button"
                @translatedLabel={{i18n (themePrefix "login_cta_label")}}
              />
            </div>
          </div>
        </div>
      </div>
    {{/if}}
  </template>
}
