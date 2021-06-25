import axios from "axios";
import { rethrowSimple } from "utils/simple-error";
import { getAppRoot } from "onload/loadConfig";
import { getGalaxyInstance } from "app";

export async function updateTool(tool_id, tool_version, inputs) {
    const current_state = {
        tool_id: tool_id,
        tool_version: tool_version,
        inputs: inputs,
    };
    const url = `${getAppRoot()}api/tools/${tool_id}/build`;
    try {
        const { data } = await axios.post(url, current_state);
        return data;
    } catch (e) {
        rethrowSimple(e);
    }
}

/** Tools data request helper **/
export async function getTool(tool_id, tool_version, job_id, history_id) {
    const Galaxy = getGalaxyInstance();
    let url = "";
    let data = {};

    // build request url and collect request data
    if (job_id) {
        url = `${getAppRoot()}api/jobs/${job_id}/build_for_rerun`;
    } else {
        url = `${getAppRoot()}api/tools/${tool_id}/build`;
        data = Object.assign({}, Galaxy.params);
        data["tool_id"] && delete data["tool_id"];
    }
    history_id && (data["history_id"] = history_id);
    tool_version && (data["tool_version"] = tool_version);

    // attach data to request url
    if (Object.entries(data).length != 0) {
        const params = new URLSearchParams(data);
        url = `${url}?${params.toString()}`;
    }

    // request tool data
    try {
        const { data } = await axios.get(url);
        return data;
    } catch (e) {
        rethrowSimple(e);
    }
}

export async function submitJob(jobDetails) {
    const url = `${getAppRoot()}api/tools`;
    const { data } = await axios.post(url, jobDetails);
    return data;
}

export async function addFavorite(userId, toolId) {
    const url = `${getAppRoot()}api/users/${userId}/favorites/tools`;
    try {
        const { data } = await axios.put(url, { object_id: toolId });
        return data;
    } catch (e) {
        rethrowSimple(e);
    }
}

export async function removeFavorite(userId, toolId) {
    const url = `${getAppRoot()}api/users/${userId}/favorites/tools/${encodeURIComponent(toolId)}`;
    try {
        const { data } = await axios.delete(url);
        return data;
    } catch (e) {
        rethrowSimple(e);
    }
}
